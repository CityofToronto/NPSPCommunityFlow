@RestResource(urlMapping='/MonerisAsyncTxResponse/*')
global class MonerisAsyncTxResponseHandler {

    @HttpPost
    global static void parseResponse() {

        try {
            // Tokens to retrieve from response message
            String mess = '';
            String resp = '';
            String respIp = '';

            Map<String, String> responseResultMap = new Map<String, String>{
                                                        'message' => null,
                                                        'response_order_id' => null,
                                                        'cardholder' => null,
                                                        'response_code' => null,
                                                        'result' => null,
                                                        'charge_total' => null,
                                                        'bank_transaction_id' => null,
                                                        'transactionKey' => null,
                                                        'time_stamp' => null,
                                                        'date_stamp' => null,
                                                        'card_num' => null,
                                                        'card' => null
                                                    };
            
            resp = RestContext.request.params.get('xml_response');
            respIp = RestContext.request.remoteAddress;
            
            // Parse XML Response
            system.debug('MonerisAsyncTxReponseHandler :: parseResponse :: resp = ' + resp);
            DOM.Document xmlDOC = new DOM.Document();
            xmlDOC.load(resp);
            DOM.XMLNode rootElement = xmlDOC.getRootElement();
            for(DOM.XMLNode xmlnodeobj:xmlDOC.getRootElement().getChildElements()) {
                // COT-2: Add response results to our map for the keys we have identified
                String keyName = xmlnodeobj.getName();
                if(!String.isEmpty(keyName) && responseResultMap.containsKey(keyName)) {
                    responseResultMap.put(keyName, xmlnodeobj.getText());
                }
            }
            system.debug('MonerisAsyncTxReponseHandler :: parseResponse :: responseResultMap = ' + responseResultMap);

            String paymentId = responseResultMap.get('response_order_id');
            paymentId = paymentId.split('-')[0];  //strip off end of response_order_id, could be a retry ex: a0755000006wEjJAAU-R01
            npe01__OppPayment__c payment = [SELECT Id, npe01__Opportunity__c, npe01__Paid__c, npe01__Check_Reference_Number__c FROM npe01__OppPayment__c WHERE Id =: paymentId];
            
            //only update payment and opportunity if it hasn't already been paid
            if(!payment.npe01__Paid__c && payment.npe01__Check_Reference_Number__c == null) {
                DMS_Settings__c dmsSettings = DMS_Settings__c.getOrgDefaults();
                payment.Transaction_Response__c = resp;
                payment.npe01__Check_Reference_Number__c = responseResultMap.get('bank_transaction_id');
                payment.Card_Type__c = responseResultMap.get('card');
                payment.Card_Number__c = responseResultMap.get('card_num');
                payment.Card_Holder__c = responseResultMap.get('cardholder');
                payment.Card_Holder__c = payment.Card_Holder__c.replace('+',' ');

                String paymentAmount = responseResultMap.get('charge_total');
                if(!String.isEmpty(paymentAmount)) {
                    payment.npe01__Payment_Amount__c = Decimal.valueOf(paymentAmount);
                }

                Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Id =: payment.npe01__Opportunity__c];

                //check result code
                String resultCode = responseResultMap.get('result');
                payment.npe01__Custom_Payment_Field__c = responseResultMap.get('response_code');

                if(resultCode == '1') { //APPROVED
                    opportunity.StageName = 'Posted';
                    opportunity.CloseDate = System.now().date();
                    opportunity.Card_Holder__c = payment.Card_Holder__c;

                    if(payment.npe01__Payment_Amount__c >= dmsSettings.Minimum_Tax_Receipt_Amount__c) {
                        opportunity.Tax_Receipt_Number__c = generateTaxReceiptNumber();
                    }

                    //Setting opportunity acknowledge status triggers email workflow automatically
                    opportunity.npsp__Acknowledgment_Status__c = 'Email Acknowledgment Now'; 
                    payment.npe01__Paid__c = true;
                    payment.npe01__Payment_Date__c = System.now().date();
                } else if(resultCode == '-1') { //CANCELLED
                    opportunity.StageName = 'Withdrawn';
                } else {  // resultCode == 0 FAILED OR DECLINED
                    opportunity.StageName = 'Withdrawn';
                }

                update payment;
                update opportunity;

            }
  
        } catch (Exception ex) {
            system.debug('MonerisAsyncTxReponseHandler :: parseResponse :: ex = ' + ex);
        }
    }

    public static String generateTaxReceiptNumber() {
        Datetime today = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        String year = (String.valueOf(today.year())).substring(2, 4);
        return generateTaxReceiptNumber(year, false);
    }

    public static String generateTaxReceiptNumber(String twoDigityear, boolean previousYear) {
        Integer taxRecieptNum = iterateReceiptNumber();
        String taxNumStr = null;
        if(taxRecieptNum != null) {
            String taxReceiptNumPad = (String.valueOf(taxRecieptNum).leftPad(5)).replace(' ','0');
            taxNumStr = 'R-' + twoDigityear;
            if(!previousYear) {
                taxNumStr += 'A-' + taxReceiptNumPad;
            }   else {
                taxNumStr += 'B-' + taxReceiptNumPad;
            }
        }
        return taxNumStr;
    }

    /** 
      * COT-1: Get a unique donation number using a lock on the select call to prevent race conditions
      */
    private static Integer iterateReceiptNumber() {
        Decimal invoiceNumber = null;
        integer numAttempts = 0;
        
        // Get a lock on a donation number to ensure its unique
        // Max out after 8 attempts to stay under the 10 second cpu time limit
        while (invoiceNumber == null && numAttempts <= 8) {
            
            try {
                DMS_Settings__c dmsSettings = DMS_Settings__c.getOrgDefaults();
                dmsSettings.Donation_Number__c = dmsSettings.Donation_Number__c + 1;
                update dmsSettings;
                invoiceNumber = dmsSettings.Donation_Number__c;
            }   catch (Exception ex) {  
                // If the donation number is locked, set the number to null, sleep and try again
                system.debug('MonerisAsyncTxReponseHandler  :: iterateReceiptNumber :: ex=' + ex);
                invoiceNumber = null;
                numAttempts++;

                // Sleep for 1 seconds
                sleep(1 * 950);   
            }
        }

        system.debug('MonerisAsyncTxReponseHandler :: iterateReceiptNumber :: invoiceNumber=' + invoiceNumber);
        return (invoiceNumber != null ? invoiceNumber.intValue() : null);
    }
    
    /**
      * COT-1: Sleep method to wait before trying to get another donation number with a lock
      */
    private static void sleep(Long milliSeconds) {
        Long timeDiff = 0;
        DateTime startTime = System.now();
        do {
            timeDiff = System.now().getTime() - startTime.getTime();
        }
        while (timeDiff <= milliSeconds);
    }
}

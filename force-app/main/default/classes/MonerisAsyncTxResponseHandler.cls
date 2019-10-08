@RestResource(urlMapping='/MonerisAsyncTxResponse/*')
global class MonerisAsyncTxResponseHandler {
    public MonerisAsyncTxResponseHandler() {

    }

    @HttpPost
    global static void parseResponse() {

        //Donation_Setings__c donationSettings = Donation_Setings__c.getOrgDefaults();

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

            // if(!Test.isRunningTest()) {
            //     resp = RestContext.request.params.get('xml_response');
            //     respIp = RestContext.request.remoteAddress;
            // } else {
            //     // Create a test message if tests are running
            //     respIp = '216.220.63.73';
            //     // Since see all data is false, only donations created in the test context will be returned
            //     Donation__c don = [SELECT Id
            //                        FROM Donation__c
            //                        WHERE CreatedDate = TODAY
            //                        LIMIT 1];

            //     // Create sample response          
            //     resp = '<response><message>APPROVED * =</message><response_order_id>' + don.id + '</response_order_id><cardholder>Brent+Lanteigne</cardholder><response_code>000</response_code><result>1</result><charge_total>' + testDonationAmount + '</charge_total><bank_transaction_id>660035510010258730</bank_transaction_id><time_stamp>14:47:45</time_stamp><date_stamp>2017-05-31</date_stamp><card_num>3735***5005</card_num><card>V</card></response>';            
            // }
            
            // Parse XML Response
            system.debug('AsynchronousTransactionResponse :: parseMonerisResponse :: resp' + resp);
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
            system.debug('AsynchronousTransactionResponse :: parseMonerisResponse :: responseResultMap' + responseResultMap);
            
            // // If tests are running, setup sample ip addresses
            // if(Test.isRunningTest()) {
            //     donationSettings.Production_Information_IP__c = '216.220.63.73';
            //     donationSettings.Test_Environment_Information_IP__c = '216.220.63.73';
            // }

            // // Check the IP addresses response IP vs. configured ip addresses
            // if(donationSettings.Production_Information_IP__c.contains(respIp) || 
            //    donationSettings.Test_Environment_Information_IP__c.contains(respIp)) {            
                
            //     // COT-1: Updated to retrieve tax receipt auto number
            //     List<Donation__c> listDon = [SELECT Id, Donation_Amount__c, Parameters__c, Status__c, Card_Holder_Name__c, Tax_Receipts__c
            //                                  FROM Donation__c 
            //                                  WHERE Id = :responseResultMap.get('response_order_id')
            //                                  LIMIT 1];
            //     system.debug('AsynchronousTransactionResponse :: parseMonerisResponse :: listDon' + listDon);

            //     if(listDon != null && listDon.size() == 1) {

            //         Donation__c donation = listDon[0];                

            //         // COT-2: Update the donation based on the transaction verification response (Approved and Declined)
            //         donation.Parameters__c = resp;
            //         donation.Card_Holder_Name__c = responseResultMap.get('cardholder');
            //         donation.Card_Holder_Name__c = donation.Card_Holder_Name__c.replace('+',' ');
            //         donation.Bank_Transaction_ID__c = responseResultMap.get('bank_transaction_id');
            //         // COT-33: ADded additional fields to the donation record based on the Moneris response
            //         donation.Moneris_Card_Number__c = responseResultMap.get('card_num');
            //         donation.Moneris_Card_Type__c = responseResultMap.get('card');       
            //         donation.Moneris_Order_ID__c = responseResultMap.get('response_order_id');
            //         donation.Moneris_Response_Code__c = responseResultMap.get('response_code');
            //         // Create a date time based on the moneris date and time stamp fields
            //         String dateStamp = responseResultMap.get('date_stamp');
            //         String timeStamp = responseResultMap.get('time_stamp');
            //         if(!String.isEmpty(dateStamp) && !String.isEmpty(timeStamp)) {
            //             List<String> dateArray = dateStamp.split('-');
            //             List<String> timeArray = timeStamp.split(':');
            //             Datetime monerisTimeStamp = Datetime.newInstance(Integer.valueOf(dateArray.get(0)), Integer.valueOf(dateArray.get(1)), Integer.valueOf(dateArray.get(2)),
            //                                                              Integer.valueOf(timeArray.get(0)), Integer.valueOf(timeArray.get(1)), Integer.valueOf(timeArray.get(2)));
            //             donation.Moneris_Date_Time_Stamp__c = monerisTimeStamp;
            //         }
            //         String amount = responseResultMap.get('charge_total');
            //         Decimal amountValue = Decimal.valueOf(amount);
            //         donation.Donation_Amount_Moneris__c = amountValue;

            //         // Set the donation status based on the result code from Moneris
            //         String resultCode = responseResultMap.get('result');
            //         Integer resultCodeValue = Integer.valueOf(resultCode);
            //         if(resultCodeValue != null && resultCodeValue == 1) {   // Approved
            //             donation.Status__c = 'Accepted';

            //             // Only set the tax receipt # if the transaction was approved
            //             // COT-1: Updated to get a receipt number using a lock from the custom setting
            //             // COT-65: Updated to only set the tax receipt # of the amount is greater than or equal to the threshold
            //             if(donation.Donation_Amount_Moneris__c >= donationSettings.Minimal_donation_amount_for_tax_receipt__c) {
            //                 donation.Tax_Receipts__c = generateTaxReceiptNumber();
            //             }
                        
            //             // Any accepted donations without a tax receipt # will be flagged for accounting to address manually
            //             // This may occur if a lock cant be obtained on the sequence #
            //         } else {  // Declined
            //             donation.Status__c = 'Declined';
            //         }

            //         // Update the donation (Card Holder, Amount, Status) based on the transaction response from Moneris
            //         system.debug('AsynchronousTransactionResponse :: parseMonerisResponse :: donation (postUpdate)' + donation);
            //         update donation;                  
            //    }  
            //}
        } catch (Exception ex) {
            system.debug('AsynchronousTransactionResponse :: parseMonerisResponse :: ex=' + ex);
        }
    }

    // /**
    //   * COT-48: Overwrote original method to pass in a prior year parameter
    //   */
    // public static String generateTaxReceiptNumber() {
    //     Datetime today = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
    //     String year = (String.valueOf(today.year())).substring(2, 4);
    //     return generateTaxReceiptNumber(year, false);
    // }

    // /**
    //   * COT-41: Generate the tax receipt # string, helper method for use by DMS and ePet
    //   */
    // public static String generateTaxReceiptNumber(String twoDigityear, boolean previousYear) {
    //     Donation_Setings__c donationSettings = Donation_Setings__c.getOrgDefaults();
    //     Integer taxRecieptNum = iterateReceiptNumber();
    //     String taxNumStr = null;
    //     if(taxRecieptNum != null) {
            
    //         String taxReceiptNumPad = (String.valueOf(taxRecieptNum).leftPad(donationSettings.Donation_Number_Number_of_Digits__c.intValue())).replace(' ','0');
    //         taxNumStr = 'R-' + twoDigityear;
    //         if(!previousYear) {
    //             taxNumStr += 'A-' + taxReceiptNumPad;
    //         }   else {
    //             taxNumStr += 'B-' + taxReceiptNumPad;
    //         }
    //     }
    //     return taxNumStr;
    // }

    // /** 
    //   * COT-1: Get a unique donation number using a lock on the select call to prevent race conditions
    //   */
    // private static Integer iterateReceiptNumber() {
    //     Decimal invoiceNumber = null;
    //     integer numAttempts = 0;
        
    //     // Get a lock on a donation number to ensure its unique
    //     // Max out after 8 attempts to stay under the 10 second cpu time limit
    //     while (invoiceNumber == null && numAttempts <= 8) {
    //         List<Donation_Setings__c> donationSettings = [SELECT Number_Donation__c 
    //                                                       FROM Donation_Setings__c 
    //                                                       LIMIT 1
    //                                                       FOR UPDATE];
    //         system.debug('AsynchronousTransactionResponse :: iterateReceiptNumber :: donationSettings=' + donationSettings);
    //         try {
    //             donationSettings[0].Number_Donation__c = donationSettings[0].Number_Donation__c + 1;
    //             system.debug('AsynchronousTransactionResponse :: iterateReceiptNumber :: donationSettings+1=' + donationSettings[0].Number_Donation__c);
    //             update donationSettings;
    //             invoiceNumber = donationSettings[0].Number_Donation__c;
    //         }   catch (Exception ex) {  
    //             // If the donation number is locked, set the number to null, sleep and try again
    //             system.debug('AsynchronousTransactionResponse :: iterateReceiptNumber :: ex=' + ex);
    //             invoiceNumber = null;
    //             numAttempts++;

    //             // Sleep for 1 seconds
    //             sleep(1 * 950);   
    //         }
    //     }

    //     system.debug('AsynchronousTransactionResponse :: iterateReceiptNumber :: invoiceNumber=' + invoiceNumber);
    //     return (invoiceNumber != null ? invoiceNumber.intValue() : null);
    // }

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

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
            
            resp = RestContext.request.params.get('xml_response');
            respIp = RestContext.request.remoteAddress;
            
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
            
            //Decrypt response order id to get opportunity id
            DMS_Settings__mdt[] dmsSettings = [SELECT Label, AES_Key_128__c, Moneris_HPP_Key__c, Moneris_Store_Id__c, Moneris_URL__c, Flow_Name__c FROM DMS_Settings__mdt];
            Map<String, DMS_Settings__mdt> dmsSettingsMap = new Map<String, DMS_Settings__mdt>();

            for(DMS_Settings__mdt settings : dmsSettings) {
                dmsSettingsMap.put(settings.Label, settings);
            }

            Blob cryptoKey = EncodingUtil.base64Decode(dmsSettingsMap.get('DEV').AES_Key_128__c);
            Blob responseId = EncodingUtil.base64Decode(responseResultMap.get('response_order_id'));
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128', cryptoKey, responseId);
            
            String opportunityId = decryptedData.toString();
            Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Id =:opportunityId];
            system.debug(opportunityId);
            
            //check result code
            String resultCode = responseResultMap.get('result');

            if(resultCode == '1') { //APPROVED
                opportunity.StageName = 'Closed Won';
                opportunity.CloseDate = System.now().date();   
            } else if(resultCode == '-1') { //DECLINED???
                opportunity.StageName = 'Needs Analysis';
            } else {  // resultCode == 0 FAILED, CANCELLED
                opportunity.StageName = 'Closed Lost';
            }

            update opportunity;
  
        } catch (Exception ex) {
            system.debug('AsynchronousTransactionResponse :: parseMonerisResponse :: ex=' + ex);
        }
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

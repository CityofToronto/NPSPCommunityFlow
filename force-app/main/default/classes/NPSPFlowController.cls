public with sharing class NPSPFlowController {
    @AuraEnabled
    public static List<sObject> executeSoql(String soql) {
        List<sObject> result = Database.query(soql);
        return result;
    }

    @AuraEnabled
    public static String encryptData(String value) {

        DMS_Settings__mdt[] dmsSettings = [SELECT Label, AES_Key_256__c, Moneris_HPP_Key__c, Moneris_Store_Id__c, Moneris_URL__c, Flow_Name__c FROM DMS_Settings__mdt];
        Map<String, DMS_Settings__mdt> dmsSettingsMap = new Map<String, DMS_Settings__mdt>();

        for(DMS_Settings__mdt settings : dmsSettings) {
            dmsSettingsMap.put(settings.Label, settings);
        }

        Blob cryptoKey = EncodingUtil.base64Decode(dmsSettingsMap.get('DEV').AES_Key_256__c);
        Blob data = Blob.valueOf(value);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);

        //String encrypted = EncodingUtil.base64Encode(encryptedData);

        //decrypt test
        //Blob datax = EncodingUtil.base64Decode(encrypted);
        //Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, datax);

        return EncodingUtil.base64Encode(encryptedData);
    }
}
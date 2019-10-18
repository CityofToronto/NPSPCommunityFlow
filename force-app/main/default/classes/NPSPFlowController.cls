global without sharing class NPSPFlowController {
    @AuraEnabled
    public static List<sObject> executeSoql(String soql) {
        List<sObject> result = Database.query(soql);
        return result;
    }

    @AuraEnabled
    public static String encryptData(String value) {

        Map<String, DMS_Settings__mdt> dmsSettingsMap = getDMSSettings();

        Blob cryptoKey = EncodingUtil.base64Decode(dmsSettingsMap.get('DEV').AES_Key_128__c);
        Blob data = Blob.valueOf(value);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);

        return EncodingUtil.base64Encode(encryptedData);
    }

    @AuraEnabled
    public static Map<String, DMS_Settings__mdt> getDMSSettings() {
        DMS_Settings__mdt[] dmsSettings = [SELECT Label, AES_Key_128__c, Moneris_HPP_Key__c, Moneris_Store_Id__c, Moneris_URL__c, Flow_Name__c FROM DMS_Settings__mdt];
        Map<String, DMS_Settings__mdt> dmsSettingsMap = new Map<String, DMS_Settings__mdt>();

        for(DMS_Settings__mdt settings : dmsSettings) {
            dmsSettingsMap.put(settings.Label, settings);
        }

        return dmsSettingsMap;
    }

    @AuraEnabled
    public static String createOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opr = new OpportunityContactRole(ContactId=contactId, OpportunityId=opportunityId);
        insert opr;
        return opr.Id;
    }

    @AuraEnabled
    public static String updateExistingContact(String contactId, String homePhone, String mobilePhone, String mailingCity, 
                            String mailingCountry, String mailingPostalCode, String mailingState, String mailingStreet) {
        
        Contact contact = [SELECT Id FROM Contact WHERE Id =:contactId];
        contact.HomePhone = homePhone;
        contact.MobilePhone = mobilePhone;
        contact.MailingCity = mailingCity;
        contact.MailingCountry = mailingCountry;
        contact.MailingPostalCode = mailingPostalCode;
        contact.MailingState = mailingState;
        contact.MailingStreet = mailingStreet;

        update contact;
        return contact.Id;
    }

    @AuraEnabled
    public static String updateOpportunityCampaign(String opportunityId, String campaignId, String campaignOwnerId) {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Id =:opportunityId];
        opportunity.CampaignId = campaignId;
        opportunity.OwnerId = campaignOwnerId;

        update opportunity;
        return opportunity.Id;
    }

    @InvocableMethod(label='Get a list of NPSP account record type ids' description='Returns account record type ids ordered HH_Account, Organization')
    public static List<List<String>> getNPSPAccountRecordTypeIds() {
        List<RecordType> recordTypes = [SELECT Id from RecordType where sObjectType='Account' AND DeveloperName IN ('HH_Account', 'Organization') AND isActive = TRUE ORDER BY DeveloperName];
        List<String> recordTypeIds = new List<String>();
		List<List<String>> recordTypeIdsList = new list<List<String>>();
        
        for(RecordType recordType : recordTypes) {
            recordTypeIds.add(recordType.Id);
        }
        
		recordTypeIdsList.add(recordTypeIds);
        return recordTypeIdsList;
    }
}

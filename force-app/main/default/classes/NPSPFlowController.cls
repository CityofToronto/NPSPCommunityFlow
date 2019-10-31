global without sharing class NPSPFlowController {
    @AuraEnabled
    public static List<sObject> executeSoql(String soql) {
        List<sObject> result = Database.query(soql);
        return result;
    }

    /*
    @AuraEnabled
    public static String encryptData(String value) {

        Map<String, DMS_Settings__mdt> dmsSettingsMap = getDMSSettings();

        Blob cryptoKey = EncodingUtil.base64Decode(dmsSettingsMap.get('Production').AES_Key_128__c);
        Blob data = Blob.valueOf(value);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);

        return EncodingUtil.base64Encode(encryptedData);
    }*/

    @AuraEnabled
    public static DMS_Settings__c getDMSSettings(){
        return DMS_Settings__c.getOrgDefaults();
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

    @AuraEnabled
    public static String updateAccountName(String accountId, String accountName) {
        Account account = [SELECT Id FROM Account WHERE Id =:accountId];
        account.Name = accountName;

        update account;
        return account.Id;
    }

    public static String doNotAcknowledgeOpporunity(String opportunityId) {
        Opportunity opportunity = [SELECT Id, npsp__Acknowledgment_Status__c FROM Opportunity WHERE Id =:opportunityId];
        opportunity.npsp__Acknowledgment_Status__c = 'Email Acknowledgment Not Sent';

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

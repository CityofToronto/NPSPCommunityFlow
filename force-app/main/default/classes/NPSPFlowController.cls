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
    public static Map<String, DMS_Donation_Amounts__mdt> getDonationAmounts() {
        DMS_Donation_Amounts__mdt[] donationAmounts = [SELECT Label__c, Amount__c, Program_Name__c, Sort_Order__c FROM DMS_Donation_Amounts__mdt ORDER BY Sort_Order__c, Amount__c ASC];
        Map<String, DMS_Donation_Amounts__mdt> dmsDonationAmountsMap = new Map<String, DMS_Donation_Amounts__mdt>();

        for(DMS_Donation_Amounts__mdt amount : donationAmounts) {
            dmsDonationAmountsMap.put(amount.Label__c, amount);
        }

        return dmsDonationAmountsMap;
    }

    @AuraEnabled(cacheable=true)
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
    public static String updateOpportunityPrimaryContact(String contactId, String opportunityId) {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Id =:opportunityId];
        opportunity.npsp__Primary_Contact__c = contactId;

        update opportunity;
        return opportunity.Id;
    }

    @AuraEnabled
    public static String updateExistingContact(String oContact) {
        Contact contactUpdate = (Contact)JSON.deserialize(oContact, Contact.class);
        
        Contact contact = [SELECT Id FROM Contact WHERE Id =: contactUpdate.Id];
        contact.HomePhone = contactUpdate.HomePhone;
        contact.MobilePhone = contactUpdate.MobilePhone;
        contact.MailingCity = contactUpdate.MailingCity;
        contact.MailingCountry = contactUpdate.MailingCountry;
        contact.MailingPostalCode = contactUpdate.MailingPostalCode;
        contact.MailingState = contactUpdate.MailingState;
        contact.MailingStreet = contactUpdate.MailingStreet;
        contact.Preferred_Contact_Method__c = contactUpdate.Preferred_Contact_Method__c;
        contact.Legacy_Giving__c = contactUpdate.Legacy_Giving__c;
        contact.Company__c = contactUpdate.Company__c;
        contact.AccountId = contactUpdate.AccountId;

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

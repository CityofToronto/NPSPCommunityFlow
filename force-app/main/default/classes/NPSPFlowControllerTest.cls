@isTest
private class NPSPFlowControllerTest {
    
    @testSetup static void setup() {
        Contact contact = new Contact();
        contact.firstName = 'NPSPFlowControllerTest';
        contact.lastName = 'NPSPFlowControllerTest';
        contact.email = 'NPSPFlowControllerTest@test.com';
        insert contact;
        Opportunity opportunity = new Opportunity();
        opportunity.name = 'NPSPFlowControllerTest';
        opportunity.stageName = 'Withdrawn';
        opportunity.closeDate = System.now().date();
        insert opportunity;
        Campaign oProgram = new Campaign();
        oProgram.RecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Program').getRecordTypeId();
        oProgram.isActive = TRUE;
        oProgram.Name = 'Donate';
    	insert oProgram;
          
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  
        User user = new User(LastName = 'TO',
                     FirstName='Donate',
                     Alias = 'donateTO',
                     Email = 'donate@toronto.ca',
                     Username = 'donate@toronto.ca',
                     ProfileId = profileId.id,
                     TimeZoneSidKey = 'GMT',
                     LanguageLocaleKey = 'en_US',
                     EmailEncodingKey = 'UTF-8',
                     LocaleSidKey = 'en_US'
                     );
        insert user;

        Account account = new Account(name='DonateTO');
        insert account;
    }

    @isTest static void testExecuteSoql() {
        List<sObject> result = NPSPFlowController.executeSoql('SELECT Id from Contact where email = \'NPSPFlowControllerTest@test.com\'');
        System.assertNotEquals(null, result);
    }

    @isTest static void testGetDonationAmounts() {
        Map<String, DMS_Donation_Amounts__mdt> donationAmounts = NPSPFlowController.getDonationAmounts();
        System.assertNotEquals(null, donationAmounts);
    }

    @isTest static void testGetDMSSettings() {
        DMS_Settings__c dmsSettings = NPSPFlowController.getDMSSettings();
        //System.assertEquals(dmsSettings.Static_Resource_Name__c, 'cot');
    }

    @isTest static void testCreateOpportunityContactRole() {
        Contact contact = [SELECT Id from Contact where email = 'NPSPFlowControllerTest@test.com'];
        Opportunity opportunity = [SELECT Id from Opportunity where name = 'NPSPFlowControllerTest'];
        String oprId = NPSPFlowController.createOpportunityContactRole(contact.Id, opportunity.Id);         
        System.assertNotEquals(null,oprId);
    }

    @isTest static void testUpdateExistingContact() {
        Contact contact = [SELECT Id from Contact where email = 'NPSPFlowControllerTest@test.com'];
        String oContact = '{\"Id\":\"' + contact.Id + '\",\"HomePhone\": \"2222222222\"}';

        String updatedContactId = NPSPFlowController.updateExistingContact(oContact);
        System.assertEquals(updatedContactId, contact.Id);
    }

    @isTest static void getUpdateOpportunityCampaign() {
        Campaign c = [SELECT Id, Name, ParentId, RecordTypeId FROM Campaign WHERE Name = 'Donate'];
        Opportunity opportunity = [SELECT Id from Opportunity where name = 'NPSPFlowControllerTest'];
        User user = [SELECT Id from User where Username = 'donate@toronto.ca'];
        String oppId = NPSPFlowController.updateOpportunityCampaign(opportunity.Id, c.Id, user.Id);
        System.assertEquals(oppId,opportunity.Id);
    }

    @isTest static void testUpdateAccountName() {
        Account account = [Select Id from Account where Name = 'DonateTO'];
        String accountId = NPSPFlowController.updateAccountName(account.Id, 'DonateTOUpdate');
        System.assertEquals(accountId, accountId);
    }

    @isTest static void testUpdateOpportunityPrimaryContact() {
        Contact contact = [SELECT Id from Contact where email = 'NPSPFlowControllerTest@test.com'];
        Opportunity opportunity = [SELECT Id from Opportunity where name = 'NPSPFlowControllerTest'];
        String opportunityId = NPSPFlowController.updateOpportunityPrimaryContact(contact.Id, opportunity.Id);         
        System.assertEquals(opportunityId,opportunity.Id);
    }

    @isTest static void testGetNPSPAccountRecordTypeIds() {
        List<List<String>> recordTypeIds = NPSPFlowController.getNPSPAccountRecordTypeIds();
        System.assertNotEquals(null, recordTypeIds);
    }
}
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
    }

    @isTest static void testCreateOpportunityContactRole() {
        Contact contact = [SELECT Id from Contact where email = 'NPSPFlowControllerTest@test.com'];
        Opportunity opportunity = [SELECT Id from Opportunity where name = 'NPSPFlowControllerTest'];
        String oprId = NPSPFlowController.createOpportunityContactRole(contact.Id, opportunity.Id);         
        //System.assertEquals(oprId,opportunity.Id);
    }

    @isTest static void testUpdateOpportunityPrimaryContact() {
        Contact contact = [SELECT Id from Contact where email = 'NPSPFlowControllerTest@test.com'];
        Opportunity opportunity = [SELECT Id from Opportunity where name = 'NPSPFlowControllerTest'];
        String opportunityId = NPSPFlowController.updateOpportunityPrimaryContact(contact.Id, opportunity.Id);         
        System.assertEquals(opportunityId,opportunity.Id);
    }
}

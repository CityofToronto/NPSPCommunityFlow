trigger DMSTrigger on Opportunity (after update) {

    for(Opportunity opportunity : Trigger.New) {
        
        if(opportunity.npsp__Acknowledgment_Status__c == 'Email Acknowledgment Now') {
            Contact primary = [Select Email, npsp__Do_Not_Contact__c, HasOptedOutOfEmail, npsp__Deceased__c from Contact where Id =: opportunity.npsp__Primary_Contact__c]; 
        
            if(opportunity.StageName == 'Posted' && primary.Email != NULL && !primary.npsp__Do_Not_Contact__c && !primary.HasOptedOutOfEmail && !primary.npsp__Deceased__c) {
                DMSEmailHandler.sendEmail(opportunity.npsp__Primary_Contact__c, opportunity.Id);
            } else {
                NPSPFlowController.doNotAcknowledgeOpporunity(opportunity.Id);    
            }
        }
        
    }
    
}
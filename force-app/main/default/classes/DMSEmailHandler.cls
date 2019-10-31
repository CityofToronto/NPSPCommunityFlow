public without sharing class DMSEmailHandler {

    public static void sendEmail(String contactId, String opportunityId) {
        DMS_Settings__c dmsSettings = DMS_Settings__c.getOrgDefaults();
		
        Opportunity opportunity = [Select npsp__Acknowledgment_Status__c, npsp__Acknowledgment_Date__c, Please_send_eCard__c from Opportunity where id =: opportunityId];
        opportunity.npsp__Acknowledgment_Status__c = 'Email Acknowledgment Not Sent';

        if(!dmsSettings.Disable_Email__c) {
            
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            EmailTemplate thankYouTemplate = [select Id FROM EmailTemplate WHERE DeveloperName = 'DMSThankYouWithReceiptAttachment' limit 1];

            Messaging.SingleEmailMessage thankYouEmail = new Messaging.SingleEmailMessage();
            thankYouEmail.setTemplateId(thankYouTemplate.Id);
            thankYouEmail.setTargetObjectId(contactId);
            thankYouEmail.setWhatId(opportunityId);
            emailsToSend.add(thankYouEmail);

            if(opportunity.Please_send_eCard__c) {
                EmailTemplate eCardTemplate = [select Id FROM EmailTemplate WHERE DeveloperName = 'DMSECard' limit 1];

                Messaging.SingleEmailMessage eCardEmail = new Messaging.SingleEmailMessage();
                eCardEmail.setTemplateId(eCardTemplate.Id);
                eCardEmail.setTargetObjectId(contactId);
                eCardEmail.setWhatId(opportunityId);
                emailsToSend.add(eCardEmail);
            }

            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);

            if (results[0].success) {
                opportunity.npsp__Acknowledgment_Status__c = 'Acknowledged';
                opportunity.npsp__Acknowledgment_Date__c = System.now().date();
                system.debug(results);
            } else {
                system.debug('DMSEmailHandler error: ' + results);
            }

        }
        
        update opportunity;
    }
    
    //DOES NOT CURRENTLY WORK
    private static Messaging.EmailFileAttachment getDMSTaxReceiptAttachment(String contactId, String opportunityId) {
        EmailTemplate taxTemplate = [select Id FROM EmailTemplate WHERE DeveloperName = 'DMSTaxReceipt' limit 1];
		
        Messaging.SingleEmailMessage taxEmail = Messaging.renderStoredEmailTemplate(taxTemplate.Id, contactId, opportunityId);
       
        if(taxEmail.getHTMLBody() != null) {
            Messaging.EmailFileAttachment taxReceiptAttachment = new Messaging.EmailFileAttachment();
            taxReceiptAttachment.setFileName('receipt.pdf');
            taxReceiptAttachment.setContentType('application/pdf');
            taxReceiptAttachment.setBody(Blob.valueOf(taxEmail.getHTMLBody()));
            return taxReceiptAttachment;
        }
        
        return null;
    }
}
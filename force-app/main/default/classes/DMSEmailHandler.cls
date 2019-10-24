public without sharing class DMSEmailHandler {

    public static void sendEmail(String contactId, String opportunityId) {
        EmailTemplate thankYouTemplate = [select Id FROM EmailTemplate WHERE DeveloperName = 'DMSThankYouWithReceiptAttachment' limit 1];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(thankYouTemplate.Id);
        mail.setTargetObjectId(contactId);
        mail.setWhatId(opportunityId);

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
        Opportunity opportunity = [Select npsp__Acknowledgment_Status__c, npsp__Acknowledgment_Date__c from Opportunity where id =: opportunityId];
        
        if (results[0].success) {
            opportunity.npsp__Acknowledgment_Status__c = 'Acknowledged';
            opportunity.npsp__Acknowledgment_Date__c = System.now().date();
            system.debug(results);
        } else {
            opportunity.npsp__Acknowledgment_Status__c = 'Email Acknowledgment Not Sent';
            system.debug('DMS mail send error: ' + results);
        }
        
        update opportunity;
    }
    
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
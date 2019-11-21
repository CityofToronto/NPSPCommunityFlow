public with sharing class InitiativeProgramController {
    
    @AuraEnabled
    public static List<Campaign> getAllActiveInitiatives() {
        return getAllActiveCampaignsByDeveloperName('Initiative');
    }

    @AuraEnabled
    public static List<Campaign> getAllActiveProgramsByParentId(String parentId) {
        return getAllActiveCampaignsByDevNameId('Program', parentId);
    }

    @AuraEnabled
    public static List<Campaign> getAllActivePrograms() {
        return getAllActiveCampaignsByDeveloperName('Program');
    }

    @AuraEnabled
    public static String getParentIdByProgramId(String programId) {
        Campaign campaign = [SELECT Id, ParentId FROM Campaign WHERE 
        RecordTypeId in (Select Id From RecordType Where SObjectType = 'Campaign' AND DeveloperName IN ('Program','Initiative')) AND isActive = TRUE AND Id = :programId];

        if(campaign.ParentId == null) { //this is probably an initiative campaign
            return campaign.Id;
        }

        return campaign.ParentId;
    }

    @AuraEnabled
    public static Campaign getCampaignByProgramName(String programName){
        Campaign campaign = [SELECT Id, ParentId FROM Campaign WHERE 
        RecordTypeId in (Select Id From RecordType Where SObjectType = 'Campaign' AND DeveloperName IN ('Program')) AND isActive = TRUE AND Name = :programName];
        return campaign;
    }

    private static List<Campaign> getAllActiveCampaignsByDeveloperName(String devName) {
        return [SELECT Id, Name FROM Campaign WHERE 
        RecordTypeId in (Select Id From RecordType Where SObjectType = 'Campaign' AND DeveloperName IN (:devName)) AND isActive = TRUE
        ORDER BY Name];
    }

    private static List<Campaign> getAllActiveCampaignsByDevNameId(String devName, String parentId) {
        return [SELECT Id, Name FROM Campaign WHERE 
        RecordTypeId in (Select Id From RecordType Where SObjectType = 'Campaign' AND DeveloperName IN (:devName)) AND ParentId = :parentId AND isActive = TRUE
        ORDER BY Name];
    }
}

@isTest
private class InitiativeProgramControllerTest {
    @testSetup static void methodName() {
        Campaign oInitiative = new Campaign();
        oInitiative.RecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Initiative').getRecordTypeId();
        oInitiative.isActive = TRUE;
        oInitiative.Name = 'Init';
    	insert oInitiative;        
        Campaign oProgram = new Campaign();
        oProgram.RecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Program').getRecordTypeId();
        oProgram.isActive = TRUE;
        oProgram.Name = 'Donate';
       	oInitiative.ParentId = oProgram.Id;
    	insert oProgram;
    }
    
    @isTest static void testGetAllActiveInitiatives() {
        List<Campaign> initiatives = InitiativeProgramController.getAllActiveInitiatives();         
        //System.assertEquals(21.11,celsius);
    }
    
    @isTest static void testGetAllActivePrograms() {
        List<Campaign> initiatives = InitiativeProgramController.getAllActivePrograms();         
        //System.assertEquals(21.11,celsius);
    }
    
    @isTest static void testGetAllActiveProgramsByParentId() {
        Campaign c = [SELECT Id, Name, ParentId, RecordTypeId FROM Campaign WHERE Name = 'Donate'];
        List<Campaign> initiatives = InitiativeProgramController.getAllActiveProgramsByParentId(c.ParentId);         
        //System.assertEquals(21.11,celsius);
    }

    @isTest static void testGetAllActivePrograms2() {
        List<Campaign> program = InitiativeProgramController.GetAllActivePrograms();         
        //System.assertEquals(21.11,celsius);
    }

    @isTest static void testGetParentIdByProgramId() {
        Campaign c = [SELECT Id, Name, ParentId, RecordTypeId FROM Campaign WHERE Name = 'Donate'];
        String parentId = InitiativeProgramController.getParentIdByProgramId(c.Id);         
        //System.assertEquals(21.11,celsius);
    }

    @isTest static void testGetCampaignByProgramName() {
        Campaign campaign = InitiativeProgramController.getCampaignByProgramName('Donate');         
        //System.assertEquals(21.11,celsius);
    }
}
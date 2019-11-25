@isTest
private class InitiativeProgramControllerTest {
    @isTest static void testGetAllActiveInitiatives() {
        List<Campaign> initiatives = InitiativeProgramController.getAllActiveInitiatives();         
        //System.assertEquals(21.11,celsius);
    }

    @isTest static void testGetAllActiveProgramsByParentId() {
        List<Campaign> initiatives = InitiativeProgramController.getAllActiveInitiatives();         
        //System.assertEquals(21.11,celsius);
    }

    @isTest static void testGetAllActivePrograms() {
        List<Campaign> program = InitiativeProgramController.getAllActiveInitiatives();         
        //System.assertEquals(21.11,celsius);
    }

    @isTest static void testGetParentIdByProgramId() {
        String parentId = InitiativeProgramController.getParentIdByProgramId('001');         
        //System.assertEquals(21.11,celsius);
    }

    @isTest static void testGetCampaignByProgramName() {
        Campaign campaign = InitiativeProgramController.getCampaignByProgramName('Donate');         
        //System.assertEquals(21.11,celsius);
    }
}

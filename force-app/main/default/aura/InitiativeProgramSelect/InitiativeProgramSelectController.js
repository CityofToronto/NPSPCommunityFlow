({
    init: function (cmp, event, helper) {

        helper.apex(cmp, "getAllActiveInitiatives", {})
        .then(function (result) {
            cmp.set('v.initiatives', result);
        }).catch(function (error) {
            //do something about the error
        });

    },

    onChangeInitiative: function (cmp, evt, helper) {
        var parentId = cmp.find('initiativeSelect').get('v.value');

        cmp.set('v.initiativeIdSelected', parentId);
        helper.apex(cmp, "getAllActiveProgramsByParentId", {parentId : parentId})
        .then(function (result) {
            cmp.set('v.programs', result);
        }).catch(function (error) {
            //do something about the error
        });
    },

    onChangeProgram: function (cmp, evt, helper) {
        var programId = cmp.find('programSelect').get('v.value');
        cmp.set('v.programIdSelected', programId);
    }
})

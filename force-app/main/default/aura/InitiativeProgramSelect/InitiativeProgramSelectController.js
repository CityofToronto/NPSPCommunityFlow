({
    init: function (cmp, event, helper) {

        helper.apex(cmp, "getAllActiveInitiatives", {})
        .then(function (result) {
            cmp.set('v.initiatives', result);
        }).catch(function (error) {
            //do something about the error
        });

    },

    onChange: function (cmp, evt, helper) {
        var parentId = cmp.find('initiativeSelect').get('v.value');

        helper.apex(cmp, "getAllActiveProgramsByParentId", {parentId : parentId})
        .then(function (result) {
            cmp.set('v.programs', result);
        }).catch(function (error) {
            //do something about the error
        });
    }
})

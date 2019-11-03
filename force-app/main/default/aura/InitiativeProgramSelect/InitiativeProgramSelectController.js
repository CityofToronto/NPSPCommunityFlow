({
    init: function (cmp, event, helper) {
        helper.apex(cmp, "getAllActiveInitiatives", {})
        .then(function (result) {
            cmp.set('v.initiatives', result);

            if(sessionStorage) {
                if(sessionStorage.getItem('initiativeSelect')) {
                    cmp.set('v.initiativeSelected', sessionStorage.getItem('initiativeSelect'));
                    cmp.find('initiativeSelect').set('v.value',sessionStorage.getItem('initiativeSelect'));
                }
            }

            $A.enqueueAction(cmp.get('c.onChangeInitiative'));
            
        }).catch(function (error) {
            //do something about the error
        });

        cmp.set('v.validate', function() {
            var initiative = cmp.find('initiativeSelect').get('v.value');
            var program = cmp.find('programSelect').get('v.value');
            cmp.set('v.initiativeIdSelected', initiative);
            cmp.set('v.programIdSelected', program);

            if(sessionStorage)  {
                sessionStorage.setItem('initiativeSelect',initiative);
                sessionStorage.setItem('programSelect',program);
            }

            if(initiative && initiative.length>0 && program && program.length>0) {
                return { isValid: true };
            } else {
                return { isValid: false, errorMessage: 'Please select an initiative and a program.' };
            }
        });
    },

    onChangeInitiative: function (cmp, evt, helper) {
        var parentId = cmp.find('initiativeSelect').get('v.value');

        helper.apex(cmp, "getAllActiveProgramsByParentId", {parentId : parentId})
        .then(function (result) {
            cmp.set('v.programs', result);

            if(sessionStorage) {
                if(sessionStorage.getItem('programSelect')) {
                    cmp.set('v.programSelected', sessionStorage.getItem('programSelect'));
                    cmp.find('programSelect').set('v.value',sessionStorage.getItem('programSelect'));
                }
            }

            return;
        }).catch(function (error) {
            return;
            //do something about the error
        });
    },

    handleApplicationEvent : function(cmp, event, helper) {
        var programId = event.getParam("programId");
        var programName = event.getParam("programName");
        var changeInitiativeAction = cmp.get("c.onChangeInitiative");
        if(programName) {
            helper.apex(cmp, "getCampaignByProgramName", {programName : programName})
            .then(function (result) {
                cmp.find('initiativeSelect').set('v.value',result.ParentId);
                cmp.set('v.initiativeIdSelected', result.ParentId);

                changeInitiativeAction.setCallback(this, function(response) {
                    setTimeout(function () {
                        cmp.find('programSelect').set('v.value',result.Id);
                    }, 800);
                });
                $A.enqueueAction(changeInitiativeAction);
            }).catch(function (error) {
                //do something about the error
            });
        } else {
            helper.apex(cmp, "getParentIdByProgramId", {programId : programId})
            .then(function (result) {
                cmp.find('initiativeSelect').set('v.value',result);
                changeInitiativeAction.setCallback(this, function(response) {
                    setTimeout(function () {
                        cmp.find('programSelect').set('v.value',programId);
                    }, 800);
                });
                $A.enqueueAction(changeInitiativeAction);
            }).catch(function (error) {
                //do something about the error
            });
        }
    }
})

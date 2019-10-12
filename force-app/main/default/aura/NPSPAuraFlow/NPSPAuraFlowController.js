({
    init : function (component, event, helper) {
        var inputProgram = typeof helper.getUrlVars()["program"] === "undefined" ? " " : helper.getUrlVars()["program"];
        //console.log(inputProgram);
        var flowInputVariables = [
            {
               name : "Input_Program",
               type : "String",
               value: inputProgram
            }
        ];

        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("DonateTO", flowInputVariables);

        helper.soql(component, "SELECT Label, AES_Key_256__c, Moneris_HPP_Key__c, Moneris_Store_Id__c, Moneris_URL__c, Flow_Name__c FROM DMS_Settings__mdt")
        .then(function (settings) {
            settings.forEach(function(item, index) {
                helper.settingsObj[item.Label] = item;
            });

            component.set('v.dmsSettings', helper.settingsObj);
        })
    },
        
    handleStatusChange : function (component, event, helper) {
        var outputVariables = event.getParam("outputVariables");
        var formResults = {};

        outputVariables.forEach(function(item, index) {
            formResults[item.name] = item;
        });
        console.log(formResults);
        if(event.getParam("status") === "FINISHED") {
            component.find("paymentAmount").set("v.value", formResults.Donation_Amount_Value.value.toFixed(2));
            component.find("orderId").set("v.value", formResults.savedOpportunityId.value);

            var contactId = formResults.existingContactId.value;
            var opportunityId = formResults.savedOpportunityId.value;
            helper.apex(component, "createOpportunityContactRole", { contactId : contactId, opportunityId: opportunityId })
            .then(function (result) {

            }).catch(function (error) {
                //do something about the error
            });

            var homePhone = formResults.UpdateContactHomePhone.value;
            
            if(homePhone && homePhone.length > 0) {
                var mobilePhone = formResults.UpdateContactMobilePhone.value; 
                var mailingCity = formResults.UpdateContactMailingCity.value; 
                var mailingCountry = formResults.UpdateContactMailingCountry.value; 
                var mailingPostalCode = formResults.UpdateContactMailingPostalCode.value; 
                var mailingState = formResults.UpdateContactMailingState.value;
                var mailingStreet = formResults.UpdateContactMailingStreet.value;
                helper.apex(component, "updateExistingContact", { contactId:contactId,homePhone:homePhone,mobilePhone:mobilePhone,
                    mailingCity:mailingCity,mailingCountry:mailingCountry,mailingPostalCode:mailingPostalCode,
                    mailingState:mailingState,mailingStreet:mailingStreet })
                .then(function (result) {

                }).catch(function (error) {
                    //do something about the error
                });
            }
        }

        //Flow has looped again, if the form is complete submit it to Moneris
        if(event.getParam("status") === "STARTED") {
            var orderId = component.find("orderId").get("v.value");
            var amount = component.find("paymentAmount").get("v.value");

            if(orderId && orderId.length>0 && amount && amount>0) {
                helper.apex(component, "encryptData", { value : orderId})
                .then(function (result) {
                    component.find("orderId").set("v.value", result);
                    component.find("paymentForm").getElement().submit();
                }).catch(function (error) {
                    //do something about the error
                });
            }
        }
     }
})

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

        helper.apex(component, "getDMSSettings", {})
        .then(function (settings) {
            component.set('v.dmsSettings', settings);
        })
    },
        
    handleStatusChange : function (component, event, helper) {
        var outputVariables = event.getParam("outputVariables");
        var formResults = {};

        outputVariables.forEach(function(item, index) {
            formResults[item.name] = item;
        });
        console.log(formResults);

        //Flow started, send event notification to set program automatically if provided in url
        if(event.getParam("status") === "STARTED") {
            if(formResults.Input_Program.value.trim()) {
                var appEvent = $A.get("e.c:SetProgramEvent");
                appEvent.setParams({"programId" : formResults.Input_Program.value});
                appEvent.fire();
            }

            $A.util.addClass(component.find("loadingMessage"), "hidden");
        }

        if(event.getParam("status") === "FINISHED") {
            component.find("paymentAmount").set("v.value", formResults.Donation_Amount_Value.value.toFixed(2));
            component.find("orderId").set("v.value", formResults.savedPaymentId.value);

            var contactId = formResults.existingContactId.value;
            var opportunityId = formResults.savedOpportunityId.value;
            var campaignId = formResults.selectedProgramId.value;
            var campaignOwnerId = formResults.campaignRecordOwnerId.value;

            // helper.apex(component, "createOpportunityContactRole", { contactId : contactId, opportunityId: opportunityId })
            // .then(function (result) {

            // }).catch(function (error) {
            //     //do something about the error
            // });

            helper.apex(component, "updateOpportunityCampaign", { opportunityId : opportunityId, campaignId: campaignId, campaignOwnerId: campaignOwnerId })
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

            //Submit form to Moneris
            component.find("paymentForm").getElement().submit();
        }
     }
})

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

        window.addEventListener("message", $A.getCallback(function(event) {
            if(event.data.action && event.data.action == 'lock') {
                $A.util.removeClass(component.find("errorMessage"), "hidden");
                window.scrollTo({left: 0,top: 0,behavior: 'smooth'});
            }
        }), false);
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

            var pubsub = component.find('pubsub');
            pubsub.fireEvent('pageRenderEvent', {title : formResults.PageTitle.value, flowNavigation : true});
        }

        if(event.getParam("status") === "FINISHED") {
            var contactId = formResults.existingContactId.value;
            var opportunityId = formResults.savedOpportunityId.value;
            var campaignId = formResults.selectedProgramId.value;
            var campaignOwnerId = formResults.campaignRecordOwnerId.value;
            var donationAmount = formResults.DonationAmountNumber.value.toFixed(2);
            var maxDonationAmount = component.get('v.dmsSettings').Maximum_Donation_Amount__c;
            var minDonationAmount = component.get('v.dmsSettings').Minimum_Donation_Amount__c;
            
            component.find("paymentAmount").set("v.value", donationAmount);
            component.find("recurAmount").set("v.value", donationAmount);
            component.find("orderId").set("v.value", formResults.savedPaymentId.value);

            helper.apex(component, "updateOpportunityPrimaryContact", { contactId : contactId, opportunityId: opportunityId })
            .then(function (result) {

            }).catch(function (error) {
                //do something about the error
            });

            //changes owner of opportunity campaign and opportunity owner to the owner of the campaign
            helper.apex(component, "updateOpportunityCampaign", { opportunityId : opportunityId, campaignId: campaignId, campaignOwnerId: campaignOwnerId })
            .then(function (result) {

            }).catch(function (error) {
                //do something about the error
            });

            //update Account name if needed i.e. address change
            var accountName = formResults.UpdateAccountName.value;
            var accountId = formResults.accountIdOfExistingContact.value;
            if(accountName && accountName.length > 0) {
                helper.apex(component, "updateAccountName", { accountId:accountId, accountName:accountName })
                .then(function (result) {

                }).catch(function (error) {
                    //do something about the error
                });
            }

            //update existing contact if needed
            var homePhone = formResults.UpdateContactHomePhone.value;
            if(homePhone && homePhone.length > 0) {
                var contact = {};
                contact.Id = contactId;
                contact.HomePhone = homePhone;
                contact.MobilePhone = formResults.UpdateContactMobilePhone.value; 
                contact.MailingCity = formResults.UpdateContactMailingCity.value; 
                contact.MailingCountry = formResults.UpdateContactMailingCountry.value; 
                contact.MailingPostalCode = formResults.UpdateContactMailingPostalCode.value; 
                contact.MailingState = formResults.UpdateContactMailingState.value;
                contact.MailingStreet = formResults.UpdateContactMailingStreet.value;
                contact.Preferred_Contact_Method__c = formResults.UpdateContactPreferredContactMethod.value;
                contact.Legacy_Giving__c = formResults.UpdateContactLegacyGiving.value;
                contact.Company__c = formResults.UpdateContactCompany.value;
                contact.AccountId = formResults.UpdateContactAccountId.value;

                helper.apex(component, "updateExistingContact", { oContact : JSON.stringify(contact) })
                .then(function (result) {

                }).catch(function (error) {
                    //do something about the error
                });
            }

            //Submit form to Moneris only if an opporunity was created
            if(opportunityId !== null && donationAmount >= minDonationAmount && donationAmount <= maxDonationAmount) {
                //clean up session storage
                if(sessionStorage) {
                    sessionStorage.clear();
                }
                component.find("paymentForm").getElement().submit();
            } else {
                $A.util.removeClass(component.find("errorMessage"), "hidden");
            }
        }
     },
     
     handleDestroy: function(component) {
        var pubsub = component.find('pubsub');
        pubsub.unregisterAllListeners();
     }
})

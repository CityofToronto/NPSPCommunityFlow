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

        if(formResults.outputStatusFinished.value === true) {
            var navigate = component.get('v.navigateFlow');
            console.log(navigate);
            navigate("FINISH");
        }

        if(event.getParam("status") === "FINISHED") {
            console.log(formResults);
            component.find("paymentAmount").set("v.value", formResults.Donation_Amount_Value.value);

            // helper.apex(component, "encryptData", { value : formResults.savedOpportunityId.value})
            // .then(function (result) {
            //     component.find("orderId").set("v.value", result);
            //     component.find("paymentForm").getElement().submit();
            // }).catch(function (error) {
            //     //do something about the error
            // });

            component.find("paymentForm").getElement().submit();
        }
     }
})

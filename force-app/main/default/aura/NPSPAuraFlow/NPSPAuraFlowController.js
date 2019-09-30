({
    init : function (component, event, helper) {
        var inputProgram = typeof helper.getUrlVars()["program"] === "undefined" ? " " : helper.getUrlVars()["program"];
        console.log(inputProgram);
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
    },
        
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            console.log(outputVariables);
         //   for(var i = 0; i < outputVariables.length; i++) {
         //      outputVar = outputVariables[i];
         //      console.log(outputVar);
         //   }

            component.find("paymentForm").getElement().submit();
        }
     },

    handleSubmit : function (component, event, helper) {
        var outputVariables = event.getParam("outputVariables");
        var outputVar;
        console.log(outputVariables);
    }
})

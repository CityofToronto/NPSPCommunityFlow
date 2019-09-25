({
    apex: function(cmp, method, params) {
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c." + method);
            action.setParams(params);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },

    soql: function (cmp, query) {
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c.executeSoql");
            action.setParams({soql: query});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    }
})

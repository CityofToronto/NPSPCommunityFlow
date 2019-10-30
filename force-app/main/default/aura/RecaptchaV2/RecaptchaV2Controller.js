({
    init : function(component, event, helper) {
        //re-use existing application event and send message to customflowfooter
        var appEvent = $A.get("e.c:SetProgramEvent");
        appEvent.setParams({"programId" : "Lock"});
        appEvent.fire();

        if (window.addEventListener) {
            window.addEventListener("message", function(msg) {
                appEvent.setParams({"programId" : msg.data});
                appEvent.fire();
            }, false);
        } else {
            window.attachEvent("onmessage", function(msg) {
                appEvent.setParams({"programId" : msg.data});
                appEvent.fire();
            });
        }
    }
})

({
    init : function(component, event, helper) {
        if (window.addEventListener) {
            window.addEventListener("message", function(msg) {
                console.log(msg);
                window.data=msg.data;
                this.data=msg.data;
                if(this.data!=='Unlock') {
                    window.address=msg.data;
                }
            }, false);
        } else {
            window.attachEvent("onmessage", function(msg) {
                console.log(msg);
                window.data=msg.data;
                this.data=msg.data;
                if(this.data!=='Unlock') {
                    window.address=msg.data;
                }
            });
        }
    }
})

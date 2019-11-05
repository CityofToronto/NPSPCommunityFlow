({
    init : function(component, event, helper) {
        let vfOrigin = location.protocol + '//' + location.hostname;
        var eventCheck = $A.getCallback(function(event) {
            if (event.origin !== vfOrigin) {
                return;
            }
            // let captchEl = document.getElementById('recaptchaIframe');
            // if(event.data.captchaVisible === 'visible') {
            //     captchEl.classList.add('reCaptchaBig');
            //     captchEl.classList.remove('reCaptchaSmall');
            // } else {
            //     captchEl.classList.remove('reCaptchaBig');
            //     captchEl.classList.add('reCaptchaSmall');
            // }

            if(event.data.action === 'verify') {
                helper.apex(component, "verify", {token: event.data.token})
                .then(function (results) {                        
                    var oResults = JSON.parse(results);

                    if(oResults && oResults.success) {
                        if(oResults.success == true && oResults.score >= 0.7) {
                            //check results and figure out what to do
                            parent.postMessage({action: 'unlock'}, vfOrigin);
                        } else {
                            parent.postMessage({action: 'lock'}, vfOrigin);
                        }
                    }
                })
            }

            window.removeEventListener("message", eventCheck, false);
        });

        if (window.addEventListener) {
            window.addEventListener("message", eventCheck, false);
        }
    }
})
({
    init : function(component, event, helper) {
        let vfOrigin = location.protocol + '//' + location.hostname;
        if (window.addEventListener) {
            window.addEventListener("message", function(event) {
                if (event.origin !== vfOrigin) {
                	return;
            	}
                let captchEl = document.getElementById('recaptchaIframe');
                if(event.data.captchaVisible === 'visible') {
                    captchEl.classList.add('reCaptchaBig');
                    captchEl.classList.remove('reCaptchaSmall');
                } else {
                    captchEl.classList.remove('reCaptchaBig');
                    captchEl.classList.add('reCaptchaSmall');
                }
            }, false);
        }
    }
})
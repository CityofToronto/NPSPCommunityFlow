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

        helper.apex(component, "verify", {token: '03AOLTBLSWrT6L1b0ljO5G7oOPe5uXS_iF6fMCi3UGQ8GkDFyBAD0fOfYyYPqqSg6PbHy7Shj_fW9ZvfyCbPDIKeW9Sp47K0Fz9LNNFgFgxHiquK6v6GE9Pg9RNVgePa6NB-BqAr2CZZNZaw88HsDfHPHFxo9ByUg4wIhTT1ZB_O8T5x-XCRZN-VmsYR8j9NeTDebBAo2ZGEhm3q31QunTG5DGm6WYfCZxFGZgvKCbaI_0y22bD0b5ZforHD4GtplTqKEGvokT8_FUQereI3L9sbzu9AzaKXZtcbbyMj9qLKEp8Lw3OWpe2InUOOCpTcyZ8wO445DjAzJpV9ywJqmX-lAQgROHc5obQoJg1O7zvk3HjZv9G6yUfC-ayhmjYCSz1VWf4ZmryxdCCcrywNYzkvslq3a1GfFHrnHQWdLvx2vF9D9wybnJyEha-yZM9_IxpkxVgR_aypjGvTfmG_cUzHrrwmgVoul6LLy_9b92d7Yj7B7Fr6n88loX3zOkxIuBTan9oMpOgiQXIpiA-vFDoVdEddeE_M0Fbw'})
        .then(function (results) {
            console.log(results);
        })
    }
})
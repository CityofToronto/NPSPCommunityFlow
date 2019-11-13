({
   init : function(cmp, event, helper) {
      // Figure out which buttons to display
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            cmp.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            cmp.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            cmp.set("v.canNext", true);
         } else if (availableActions[i] == "FINISH") {
            cmp.set("v.canFinish", true);
         }
      }

      //recaptcha callback message
      window.addEventListener("message", function(event) {
      	if(event.data.action && event.data.action == 'unlock') {
            cmp.set('v.isDisabled', false);  

            var navigate = cmp.get('v.navigateFlow');
            navigate(cmp.get('v.actionClicked'));
         } else if(event.data.action && event.data.action == 'lock') {
        	   cmp.set('v.isDisabled', true); 
         }
      }, false);
    },
         
   onButtonPressed: function(cmp, event, helper) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();

      if(actionClicked === 'CANCEL') {
         location.href="https://toronto.ca/donate";
      }

      // Figure out which action was called, save the action for after recaptcha check
      cmp.set('v.actionClicked', actionClicked);

      //execute captcha check
      if(document.getElementById("recaptchaIframe")) {
         let vfOrigin = location.protocol + '//' + location.hostname;
         var recaptchaIFrame = document.getElementById("recaptchaIframe").contentWindow;
         recaptchaIFrame.postMessage({action: 'execute'}, vfOrigin);
      } else {
         var navigate = cmp.get('v.navigateFlow');
         navigate(actionClicked);
      }
   }
 })

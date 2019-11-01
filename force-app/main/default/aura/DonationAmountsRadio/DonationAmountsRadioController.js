({
    init: function (cmp, event, helper) {
        helper.apex(cmp, "getDMSSettings", {})
        .then(function (results) {
            cmp.set('v.dmsSettings', results);
            var jsonStr = JSON.stringify(eval(results.Donation_Amounts__c));
            cmp.set('v.donationAmounts', JSON.parse(jsonStr));

            if(sessionStorage) {
                if(sessionStorage.getItem('donationAmount')) {
                    cmp.set('v.radioGrpValue', sessionStorage.getItem('donationSelected'));

                    if(sessionStorage.getItem('donationSelected') === 'Other') {
                        $A.util.removeClass(cmp.find('otherAmount'), 'slds-hide');
                        cmp.find('otherAmount').set('v.value',sessionStorage.getItem('donationAmount'));
                    }
                }
            }

        }).catch(function (error) {
            console.log(error);
            //do something about the error
        });

        cmp.set('v.validate', function() {
            var amount = cmp.get('v.donationAmount');
            var amountSelected = cmp.get('v.radioGrpValue');
            var dmsSettings = cmp.get('v.dmsSettings');
 
            if(sessionStorage)  {
                 sessionStorage.setItem('donationAmount',amount);
                 sessionStorage.setItem('donationSelected',amountSelected);
            }

            if(amount && amount >= dmsSettings.Minimum_Donation_Amount__c && amount <= dmsSettings.Maximum_Donation_Amount__c) {
                return { isValid: true };
            } else if(amount < dmsSettings.Minimum_Donation_Amount__c) {
                return { isValid: false, errorMessage: 'Minimum donation amount is $' +  dmsSettings.Minimum_Donation_Amount__c};
            } else if(amount > dmsSettings.Maximum_Donation_Amount__c) {
                return { isValid: false, errorMessage: 'Maximum donation amount is $' +  dmsSettings.Maximum_Donation_Amount__c};
            } else {
                return { isValid: false, errorMessage: 'Please select or enter a donation amount.' };
            }
        });
    },

    handleAmountChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        var otherTextField = cmp.find('otherAmount');

        if(changeValue === 'Other') {
            $A.util.removeClass(otherTextField, 'slds-hide');
        } else if(changeValue === '') {

        } else {
            $A.util.addClass(otherTextField, 'slds-hide');
            cmp.set('v.donationAmount', Number(changeValue));
        }
    },

    handleOtherAmountChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        cmp.set('v.donationAmount', Number(changeValue));
    }
})

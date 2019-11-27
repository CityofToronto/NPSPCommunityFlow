({
    init: function (cmp, event, helper) {
        helper.apex(cmp, "getDMSSettings", {})
        .then(function (results) {
            cmp.set('v.dmsSettings', results);

        }).catch(function (error) {
            console.log(error);
            //do something about the error
        });

        helper.apex(cmp, "getDonationAmounts", {})
        .then($A.getCallback(function (results) {
            var amounts = [];
            for(var label in results) {
                if(results.hasOwnProperty(label))
                    var value = results[label].Amount__c;
                    if(results[label].Program_Name__c)
                        value += '|'+results[label].Program_Name__c;

                    amounts.push({'label':label, 'value':value})
            }

            cmp.set('v.donationAmounts', amounts);

            if(sessionStorage && sessionStorage.getItem('donationAmount')) {
                cmp.set('v.radioGrpValue', sessionStorage.getItem('donationSelected'));

                if(sessionStorage.getItem('donationSelected') === 'Other') {
                    $A.util.removeClass(cmp.find('otherAmount'), 'slds-hide');
                    cmp.find('otherAmount').set('v.value',sessionStorage.getItem('donationAmount'));
                }

                cmp.set('v.donationAmount', sessionStorage.getItem('donationAmount'));
                    
                var changeValue = sessionStorage.getItem('donationSelected').split("|");
                cmp.set('v.lastDonationAmountValue', changeValue);
                helper.fireSetProgramEvent(changeValue[1]);
            }


        })).catch(function (error) {
            console.log(error);
            //do something about the error
        });

        cmp.set('v.validate', function() {
            var amount = cmp.get('v.donationAmount');
            var amountSelected = cmp.get('v.radioGrpValue');
            var dmsSettings = cmp.get('v.dmsSettings');

            if(sessionStorage && typeof amount !== 'undefined')  {
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

    handleAmountChange: function (cmp, event, helper) {
        var changeValue = event.getParam("value").split("|");
        var otherTextField = cmp.find('otherAmount');

        if(changeValue[0] === 'Other') {
            $A.util.removeClass(otherTextField, 'slds-hide');
        } else {
            $A.util.addClass(otherTextField, 'slds-hide');
            cmp.set('v.donationAmount', Number(changeValue[0]));
        }

        if(cmp.get('v.lastDonationAmountValue').length > 1 && changeValue.length < 2) {
            helper.fireSetProgramEvent('clear');
        } else {
            helper.fireSetProgramEvent(changeValue[1]);
        }

        cmp.set('v.lastDonationAmountValue', changeValue);
    },

    handleOtherAmountChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        cmp.set('v.donationAmount', Number(changeValue));
    }
})
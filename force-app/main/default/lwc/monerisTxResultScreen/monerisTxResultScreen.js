/* eslint-disable dot-notation */
/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import getDMSSettings from '@salesforce/apex/NPSPFlowController.getDMSSettings'

export default class MonerisTxResultScreen extends LightningElement {

    @track urlVars = {};
    @track h2Message = '';
    @track homeUrl;
    h1EventFired = false;

    @wire(CurrentPageReference) pageRef;
    
    connectedCallback() {
        this.getUrlVars();

        if (this.urlVars.message.toUpperCase().includes("APPROVED")) {
            this.h2Message = 'Thank you for your donation!'
        } else {
            this.h2Message = 'We are unable to process your donation at this time'
        }
    }

    getUrlVars() {
        decodeURIComponent(window.location.href).replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) => {
            this.urlVars[key] = value;
        });
    }

    renderedCallback() {
        if(this.template.querySelector('h1') && !this.h1EventFired) {
            fireEvent(this.pageRef, 'pageRenderEvent', {title : this.template.querySelector('h1').innerText});
            this.h1EventFired = true;

            getDMSSettings()
                .then(result => {
                    this.homeUrl = result.Donations_Home_URL__c;
                })
                .catch(() => {
            });
        }
    }
}
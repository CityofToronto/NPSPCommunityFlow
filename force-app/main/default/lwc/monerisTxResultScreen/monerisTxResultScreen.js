/* eslint-disable dot-notation */
/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';

export default class MonerisTxResultScreen extends LightningElement {

    @track urlVars = {};
    @track h2Message = '';
    
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
}
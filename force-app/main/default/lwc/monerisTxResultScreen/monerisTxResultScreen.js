/* eslint-disable dot-notation */
/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';

export default class MonerisTxResultScreen extends LightningElement {

    @track urlVars = {};
    
    connectedCallback() {
        this.getUrlVars();
    }

    getUrlVars() {
        decodeURIComponent(window.location.href).replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) => {
            this.urlVars[key] = value;
        });
    }
}
/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable @lwc/lwc/no-document-query */
import { LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

import COT from '@salesforce/resourceUrl/cot'

export default class CotSimpleHeader extends LightningElement {
    @wire(CurrentPageReference) pageRef; 

    cotLogoPrint = COT + '/img/logo-print.svg';
    cotLogo = COT + '/img/logo.svg';

    connectedCallback() {
        registerListener('pageRenderEvent', this.updateBreadCrumbNav, this);

        Promise.all([
          loadStyle(this, COT + '/css/bootstrap.min.css'),
          loadStyle(this, COT + '/css/cot.css')
        ]).then(() => {
    
          //initialize the library using a reference to the container element obtained from the DOM
          //const el = this.template.querySelector('header');

          /*eslint no-console: ["error", { allow: ["log", "error"] }] */
          //console.log(el);
        });
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    renderedCallback() {
        this.updateBreadCrumbNav({});
    }

    updateBreadCrumbNav(titleInfo) {
        let title = titleInfo.title;
        let currentBreadCrumbElem = this.template.querySelector('.breadcrumb');
        let currentBreadCrumb = currentBreadCrumbElem.innerHTML;

        if(titleInfo.flowNavigation && currentBreadCrumbElem.children.length > 2) {  //this is a page navigation from flow
          currentBreadCrumbElem.children.removeChild(currentBreadCrumbElem.children.length-1);
        }

        //if there is more to the end of the url, add a link back to the donation page in the breadcrumb
        let urlEnd = window.location.pathname.split("/").pop();
        
        if(urlEnd === 'privacy-statement')
          title = "Privacy Statement";
        if(urlEnd === 'important-notices')
          title = "Important Notices";
        if(!currentBreadCrumb.includes("DonateTO"))
          currentBreadCrumb += '<li><a href="https://toronto.ca/donate">DonateTO</a></li>'
        if(urlEnd && !title)
          currentBreadCrumb += '<li><a href="../">Donation Form</a></li>'
        if(title) {
          currentBreadCrumb += '<li>' + title + '</li>'; 
        }

        this.template.querySelector('.breadcrumb').innerHTML = currentBreadCrumb;
    }
}
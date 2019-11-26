/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable @lwc/lwc/no-document-query */
import { LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import getDMSSettings from '@salesforce/apex/NPSPFlowController.getDMSSettings'

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

      getDMSSettings()
            .then(result => {
              let title = titleInfo.title;
              let currentBreadCrumbElem = this.template.querySelector('.breadcrumb');
      
              if(titleInfo.flowNavigation && currentBreadCrumbElem.children.length > 2) {  //this is a page navigation from flow
                currentBreadCrumbElem.removeChild(currentBreadCrumbElem.childNodes[2]);
              }
      
              let currentBreadCrumb = currentBreadCrumbElem.innerHTML;
      
              //if there is more to the end of the url, add a link back to the donation page in the breadcrumb
              let urlEnd = window.location.pathname.split("/").pop();
              
              if(urlEnd === 'privacy-statement') {
                title = "Privacy Statement";
                titleInfo.flowNavigation = true;
              }
              if(urlEnd === 'important-notices') {
                title = "Important Notices";
                titleInfo.flowNavigation = true;
              }
              if(!currentBreadCrumb.includes("DonateTO"))
                currentBreadCrumb += '<li><a href="'+ result.Donations_Home_URL__c +'">DonateTO</a></li>'
              if(title && !titleInfo.flowNavigation) {
                currentBreadCrumb += '<li><a href="../">Donation Form</a></li>'
                currentBreadCrumb += '<li>' + title + '</li>'; 
              } else if(typeof title !== 'undefined') {
                currentBreadCrumb += '<li>' + title + '</li>'; 
              }
      
              this.template.querySelector('.breadcrumb').innerHTML = currentBreadCrumb;
            })
            .catch(() => {
        });
    }
}
/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable @lwc/lwc/no-document-query */
import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import COT from '@salesforce/resourceUrl/cot'

export default class CotSimpleHeader extends LightningElement {
    cotLogoPrint = COT + '/img/logo-print.svg';
    cotLogo = COT + '/img/logo.svg';

    connectedCallback() {

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

    renderedCallback() {
        let pageTitle;
        if(document.querySelector('h1')) {
          pageTitle = document.querySelector('h1').innerText;
        }
        
        let currentBreadCrumb = this.template.querySelector('.breadcrumb').innerHTML;

        if(pageTitle !== 'DonateTO') {
          currentBreadCrumb += '<li><a href="../">DonateTO</a></li>'
        }
        currentBreadCrumb += '<li>' + pageTitle + '</li>'; 

        this.template.querySelector('.breadcrumb').innerHTML = currentBreadCrumb;
    }
}
import { LightningElement } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import COT from '@salesforce/resourceUrl/cot'

export default class CotSimpleHeader extends LightningElement {
    cotLogoPrint = COT + '/img/logo-print.svg';
    cotLogo = COT + '/img/logo.svg';

    connectedCallback() {

        Promise.all([
          loadStyle(this, COT + '/css/bootstrap.min.css'),
          loadStyle(this, COT + '/css/cot.css'),
          loadStyle(this, COT + '/local_files/css/searchblox.css'),
          loadScript(this, COT + '/js/jquery-2.2.4.min.js'),
          loadScript(this, COT + '/js/bootstrap.min.js'),
          loadScript(this, COT + '/js/footer.js'),
          loadScript(this, COT + '/js/scripts.js'),
          loadScript(this, COT + '/js/search.js'),
          loadScript(this, COT + '/local_files/js/jquery.autocomplete.only.js'),
          loadScript(this, COT + '/local_files/js/searchblox-script.js')
        ]).then(() => {
    
          //initialize the library using a reference to the container element obtained from the DOM
          //const el = this.template.querySelector('header');
        });
    }
}
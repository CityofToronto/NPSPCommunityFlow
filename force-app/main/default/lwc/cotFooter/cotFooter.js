import { LightningElement } from 'lwc';

import COT from '@salesforce/resourceUrl/cot'

export default class CotFooter extends LightningElement {
    iconGroup = COT + '/img/icon-group.svg';
    iconChat = COT + '/img/icon-chat.svg';
    iconMobile = COT + '/img/icon-mobile.svg';
    icon311 = COT + '/img/icon-311.svg';
    iconFlag = COT + '/img/icon-flag.svg';

    iconTwitter = COT + '/img/icon-twitter.svg';
    iconFacebook = COT + '/img/icon-facebook.svg';
    iconInstagram = COT + '/img/icon-instagram.svg';
    iconYoutube = COT + '/img/icon-youtube.svg';
    iconLinkedin = COT + '/img/icon-linkedin.svg';
    iconViewall = COT + '/img/icon-viewall.svg';
}
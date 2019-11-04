public with sharing class ReCaptchaV3 {
    
    @AuraEnabled
    public static String verify(String token) {                
        String privateKey = '6Lfz18AUAAAAAGqgzNAa8Thiv3OrDskVISPlVSk5';
        String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
        HttpResponse r = makeRequest(baseUrl,
                    'secret=' + privateKey + 
                    '&response='  + token);
        String res = r.getBody();    
        if ( res != null ) {
            JSONParser parser = JSON.createParser(res); 
            while (parser.nextToken() != null) {
                // if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                //     (parser.getText() == 'success')) {
                //     // Get the value.
                //     parser.nextToken();
                //     return parser.getBooleanValue();
                // }
            }            
        }                       
        return res;
    }
        
    /* Private helper methods */
        
    private static HttpResponse makeRequest(string url, string body)  {
            HttpResponse response = null;
            HttpRequest req = new HttpRequest();   
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setBody (body);
            try {
                Http http = new Http();
                response = http.send(req);
                System.debug('reCAPTCHA response: ' + response);
                System.debug('reCAPTCHA body: ' + response.getBody());
            } catch(System.Exception e) {
                System.debug('ERROR: ' + e);
            }
            return response;
    }   
            
    private static String getRemoteHost() { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
    }
}

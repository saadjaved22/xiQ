public class xiQEncryption {

    
    
    private String SFbaseURL;
    private String URLPath;
    private String apexqs;
    private String enc_key;
    private String userSession;
    
    
    // Constructor for Encryption class
    public xiQEncryption () {
        enc_key = '83yos67DqY3tTEpJdRvs6XtnJ7E9pfKi';
        SFbaseUrl = 'https://headerless.xiqonline.com/search/salesforce/';
        userSession = UserInfo.getSessionId();
    }
    
    // Encodes session and query string
    // Constructs query based on the 
    public String encryptURL (String qs, String URLPath) {
        
        String query_string = encode(qs);
        String session = encode(userSession);
        
        String currURL = ApexPages.currentPage().getURL();
        String currPage = '';
        
        if ( currURL.contains('xiQIncSF1')  || currURL.contains('xiQIncSF1'.toLowerCase())) {
            currPage = ApexPages.currentPage().getURL().substringAfter('/apex/').substringBefore('?').split('__')[1];
        } else {
            currPage = ApexPages.currentPage().getURL().substringAfter('/apex/').substringBefore('?');
        }
        
        if (currPage == 'xiQAnalytics' || currPage == 'xiQLeadAnalytics') {
            SFBaseURL = 'https://workbench.xiqonline.com/dashboards/person_dashboard_salesforce/';
            apexqs = SFbaseURL + EncodingUtil.base64Encode(Blob.valueOf(qs));
        }
        else if (currPage == 'xiQNews') {
            SFbaseURL = 'https://headerless.xiqonline.com/digest/salesforce/';
            apexqs = SFbaseURL + session + '/' + query_string + '/true';
        }
        else if (currPage == 'xiQOnline') {
            SFbaseURL = 'https://salesforce.xiqonline.com/digest/salesforce/';
            apexqs = SFbaseURL + session + '/' + query_string + '/true';
        }
        else {
            apexqs = SFbaseURL + URLPath + session + '/' + query_string + '/true';
            
            
        }
        
        return apexqs;
    }
    
    // Method for AES 256 Encryption
    private String encode(String to_encode) {
        
        String encrypted = '';
        
        try{
            Blob key = Blob.valueOf(enc_key);   
            Blob encode_blob = Blob.valueOf(to_encode);
            Blob crypto_obj = Crypto.encryptwithManagedIV('AES256', key,encode_blob);
            encrypted = EncodingUtil.base64Encode(crypto_obj);
            encrypted = encrypted.replace('/', '*');
            return encrypted;
        }
        catch(Exception e) {
            xiQErrorLogger.mailError('xiQEncryption',70,e.getTypeName(),e.getMessage());
            return null;
        }
    }   
    
}
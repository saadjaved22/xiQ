/*
Author          | Date                | Description
Saad Javed       | 1/12/2020       | Release 1.1
*/


public without sharing class XIQHomeController {
    
    private String qs;
    public String apexqs {get; set;}
    
    public boolean showContent {get;set;}
    public boolean showInit {get;set;}
    public String successError {get;set;}
    public String msg {get;set;}
    
    public xiQIncSF1__xiQ_User_Tokens__c xiqToken;
    
    public boolean buttonHideShow {get;set;}
    public String buttonHideShowString {get;set;}
    public string redirectUrl {get;set;}
    public string customLabelValue {get;set;} 
    
    public XIQHomeController() {
        
        customLabelValue = 'You do not have access to xiQ app. Please contact your System Administrator'; 
        showContent = false;
        showInit = false;
        successError = 'warning';
        msg = '';
        
        
        // Get all tokens in the org.
        xiQIncSF1__xiQ_User_Tokens__c userToken = generateToken();
        
        // Proceed if token list size is greater than zero.
        if (userToken != null) {
            generateDigestURL();
            buildURL();
            redirectUrl = '/';
        } else {
            showInit = true;
            showContent = true;
            msg = 'You are not licensed. Please contact your System Administrator';
        }
    }
    
    //To generate query string for XIQ Home Tab
    public void generateDigestURL(){
        
        id myId = UserInfo.getUserId() ;
        
        try  {        
            List<xiQIncSF1__xiQ_User_Tokens__c> xiqTokenList = new List<xiQIncSF1__xiQ_User_Tokens__c>([SELECT Token__c, Notify_Email__c FROM xiQIncSF1__xiQ_User_Tokens__c WHERE User_ID__c =: myId]);
            
            if (xiqTokenList.size() > 0) {
                qs = '?email='+EncodingUtil.urlEncode(xiqTokenList[0].Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqTokenList[0].Token__c, 'UTF-8');
            } else if (xiqTokenList.size() == 0) {
                qs='';
            }
        } catch (Exception ex) {
            showContent = true;
            successError = 'error';
            msg = ex.getMessage();
            xiQErrorLogger.mailError('xiQHomeController',65,ex.getTypeName(),ex.getMessage());
        }
    }
    
    public String buildURL() {
        xiQEncryption encryptor = new xiQEncryption();        
        apexqs = encryptor.encryptURL(qs, null);
        return apexqs;
    }
    
    public void insertOrUpdateToken(){
        
        if (xiqToken !=null) {
            try {
                if (buttonHideShow) {
                    buttonHideShow = false;
                    buttonHideShowString = 'false';                 
                }
            } catch(Exception ex) {
                xiQErrorLogger.mailError('xiQHomeController',84,ex.getTypeName(),ex.getMessage());
            }
        }
    }
    
    public xiQ_User_Tokens__c generateToken(){
        
        id myId = UserInfo.getUserId() ;
        List<xiQIncSF1__xiQ_User_Tokens__c> xiqTokenList = new List<xiQIncSF1__xiQ_User_Tokens__c>([SELECT Notify_Email__c,Token__c FROM xiQIncSF1__xiQ_User_Tokens__c WHERE User_ID__c =: myId]);
        
        if (xiqTokenList.size()>0) {
            return xiqTokenList[0];
        } else if (xiqTokenList.size() == 0) {
        }
        
        return null;
    }
    
    
}
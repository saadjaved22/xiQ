/*
Author         | Date             | Description
Saad Javed       | 14/10/2020       | Release 1.1
*/


public without sharing class XIQSearchController {
    
    // Variables for Encryption
    private String URLPath;
    public String apexqs {get; set;}
    public String userSession {get; set;}

    private String qs;
    
    // Placeholder variables for sObjects
    public Account objAccount{get;set;}
    public Contact objContact{get;set;}
    public Opportunity objOpportunity{get;set;}
    public Lead objLead{get;set;}
    public String recordID;
    
    // Variables to store critical info during class execution
    public boolean showContent{get;set;}
    public boolean buttonHideShow{get;set;}
    public String buttonHideShowString{get;set;}
    public String successError{get;set;}
    public String msg{get;set;}
    public string customLabelValue{get;set;}
    
    public xiQIncSF1__xiQ_User_Tokens__c xiqToken;
    public string redirectUrl{get;set;}
    
    // Generates query string based on XIQ ID to generate Company and Executive Search URL.
    // Constructor for XIQSearchController 
    public XIQSearchController(ApexPages.StandardController controller) {   
        
        userSession = UserInfo.getSessionId();

        customLabelValue = 'You do not have access to xiQ app. Please contact your System Administrator'; 
        successError = '';
        msg = '';
        
        // Get all tokens in the org.
        xiQIncSF1__xiQ_User_Tokens__c userToken = generateToken();
        
        // Proceed if token list size is greater than zero.
        if (userToken != null) {
            buttonHideShow = false;
            buttonHideShowString = 'false';
        } else {
            successError = 'warning';
            showContent = true;
            msg = 'You are not licensed. Please contact your System Administrator';
            buttonHideShow = true;
            buttonHideShowString = 'true';
        }
        
        // Main method to generate Urls for tokens found in the org.
        generateURLS();
        buildURL();
    } 
    
    // Build query string to access backend
    public PageReference generateURLS() {
        
        try {
            String instanceUrl = String.valueOf(URL.getSalesforceBaseUrl());
            instanceUrl = instanceUrl.replace('Url:[delegate=','').replace(']','');
            recordID = ApexPages.currentPage().getParameters().get('ID');
            
            if(recordID !=null && recordID.startsWith('001')){
                objAccount = [SELECT Id,Name,Website,XIQ_Company_ID__c FROM Account WHERE ID =: recordID LIMIT 1];
                URLPath = 'Companies/';
            }
            
            if(recordID !=null && recordID.startsWith('003')){
                objContact = [SELECT Id,FirstName,LastName,Email,Account.Name,AccountID,XIQ_Company_ID__c FROM Contact WHERE ID =: recordID LIMIT 1];
                String currPage = ApexPages.currentPage().getURL().substringAfter('/apex/').substringBefore('?').split('__')[1];
                if (currPage == 'xiQAnalytics') {
                    URLPath = '';
                }
                else if (currPage == 'xiQContacts') {
                    URLPath = 'Executives/';
                }
            }
            
            if(recordID !=null && recordID.startsWith('006')){
                objOpportunity = [SELECT AccountID FROM Opportunity WHERE ID =: recordID LIMIT 10000];
                try {
                    objAccount = [SELECT Id,Name,Website,XIQ_Company_ID__c FROM Account WHERE ID =: objOpportunity.AccountID LIMIT 1];
                } catch (Exception e) {
                    showContent = true;
                    msg = 'Data (Opportunity Account) missing, no matches found!';
                    buttonHideShow = true;
                    buttonHideShowString = 'true';
                }
                
                URLPath = 'Companies/';
            }
            
            if (recordID !=null && recordID.startsWith('00Q')) {
                
                objLead= [SELECT IsConverted,ConvertedContactId,FirstName,LastName,Name,Company,Email FROM Lead WHERE ID =: recordID LIMIT 1];
                
                if(objLead.IsConverted){
                    objContact = [SELECT Id,FirstName,LastName,Email,Account.Name,AccountID,XIQ_Company_ID__c FROM Contact WHERE ID =: objLead.ConvertedContactId LIMIT 1];
                }
                
                String currPage = ApexPages.currentPage().getURL().substringAfter('/apex/').substringBefore('?').split('__')[1];
                if (currPage == 'xiQLeadAnalytics') {
                    URLPath = '';
                }
                else if (currPage == 'xiQLeads') {
                    URLPath = 'Executives/';
                }
            }
            
            redirectUrl = '/'+recordID;
            xiqToken = generateToken();
            
            if (xiqToken.Token__c == null || xiqToken.Token__c=='') {
                showContent = true;
                successError = 'warning';
                msg = 'Access denied. Please contact your System Administrator.';
                return null;
            }
                      
            qs = '';
            
            if(xiqToken !=null && objAccount != null) {
                if (objAccount.Website == null) {
                    showContent = true;
                    successError = 'warning';
                    msg = 'Data (Account Website) missing, no matches found!';
                    return null;
                }
                
                else if(objAccount.XIQ_Company_ID__c != '0' && objAccount.XIQ_Company_ID__c != null){
                    qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')+'&id='+EncodingUtil.urlEncode(objAccount.XIQ_Company_ID__c,'UTF-8')+'&account_id='+EncodingUtil.urlEncode(objAccount.ID,'UTF-8')+'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8');  
                  
                } else {
                    qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')+'&name='+EncodingUtil.urlEncode(objAccount.Name, 'UTF-8')+'&website='+EncodingUtil.urlEncode(objAccount.Website, 'UTF-8')+'&account_id='+EncodingUtil.urlEncode(objAccount.ID,'UTF-8')+'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8');
                
                }
                
            }
            
            if (xiqToken != null && objContact != null) { 
                
                if(objContact.XIQ_Company_ID__c != null && objContact.XIQ_Company_ID__c != '0'){
                    
                    // Added contact_email address field by Hasham
                    qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')
                        +'&id='+EncodingUtil.urlEncode(objContact.XIQ_Company_ID__c, 'UTF-8')+'&contact_id='+EncodingUtil.urlEncode(objContact.ID, 'UTF-8')
                        +'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8');
                    
                } else {
                    
                    // Added contact_email address fields by Hasham
                    // no xiq contact id case
                    if (objContact.FirstName!=null && objContact.Account.Name != null) {
                        qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')
                            +'&first_name='+EncodingUtil.urlEncode(objContact.FirstName, 'UTF-8')+'&last_name='+EncodingUtil.urlEncode(objContact.LastName, 'UTF-8')
                            +'&company_name='+EncodingUtil.urlEncode(objContact.Account.Name, 'UTF-8')+'&contact_id='+EncodingUtil.urlEncode(objContact.ID, 'UTF-8')
                            +'&account_id='+EncodingUtil.urlEncode(objContact.AccountID, 'UTF-8')+'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8');          
                    }
                    
                    else if (objContact.FirstName == null && objContact.Account.Name != null) { 
                        qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')
                            +'&last_name='+EncodingUtil.urlEncode(objContact.LastName, 'UTF-8')+'&company_name='+EncodingUtil.urlEncode(objContact.Account.Name, 'UTF-8')
                            +'&contact_id='+EncodingUtil.urlEncode(objContact.ID, 'UTF-8')+'&account_id='+EncodingUtil.urlEncode(objContact.AccountID, 'UTF-8')
                            +'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8'); 
                    }
                    
                    else if (objContact.FirstName == null && objContact.Account.Name == null) {
                        qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')
                            +'&last_name='+EncodingUtil.urlEncode(objContact.LastName, 'UTF-8')+'&company_name='+'&contact_id='+EncodingUtil.urlEncode(objContact.ID, 'UTF-8')
                            +'&account_id='+'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8'); 
                    }
                    
                    else if(objContact.FirstName != null && objContact.Account.Name == null){
                        qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')
                            +'&first_name='+EncodingUtil.urlEncode(objContact.FirstName, 'UTF-8')+'&last_name='+EncodingUtil.urlEncode(objContact.LastName, 'UTF-8')
                            +'&company_name='+'&contact_id='+EncodingUtil.urlEncode(objContact.ID, 'UTF-8')+'&account_id='+'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8');                        
                    }
                }
                
                if (objContact.Email != null) {
                    qs = qs +'&contact_email='+objContact.Email;
                }
            }
            
            if (xiqToken != null && objLead != null) {
               
                if (objLead.Name != null) {
                    qs = '?email='+EncodingUtil.urlEncode(xiqToken.Notify_Email__c, 'UTF-8')+'&token='+EncodingUtil.urlEncode(xiqToken.Token__c, 'UTF-8')
                        +'&first_name='+EncodingUtil.urlEncode(objLead.FirstName, 'UTF-8')+'&last_name='+EncodingUtil.urlEncode(objLead.LastName, 'UTF-8')+'&company_name='+EncodingUtil.urlEncode(objLead.Company, 'UTF-8')
                        +'&instance_url='+EncodingUtil.urlEncode(instanceUrl,'UTF-8');
                }

                
                if(objLead.Email != null){
                    qs = qs +'&contact_email='+objLead.Email;
                }
                
            }
            
        } catch (Exception e) {
            xiQErrorLogger.mailError('xiQSearchController',213,e.getTypeName(),e.getMessage());
        }        
        
        
        return null;
    }
    
    // JS encryption translated into Apex.
    // Encrypts session id and query string to build final URL
    public String buildURL () {  
        xiQEncryption encryptor = new xiQEncryption();        
        apexqs = encryptor.encryptURL(qs, URLPath);
        return apexqs;
    }
    
    //To get token If Admin/User click on Account,Contact or Opportunity before clicking setup.
    public xiQIncSF1__xiQ_User_Tokens__c generateToken(){
        List<xiQIncSF1__xiQ_User_Tokens__c> xiqTokenList = new List<xiQIncSF1__xiQ_User_Tokens__c>([SELECT Token__c,Notify_Email__c,isLicensed__c FROM xiQIncSF1__xiQ_User_Tokens__c WHERE User_ID__c =: UserInfo.getUserId()]);
        if (xiqTokenList.size()>0 && xiqTokenList[0].isLicensed__c ==true) {
            return xiqTokenList[0];
        } 
        return null;
    }
    
    public void syncCurrCompany() {   
        Id myId = Apexpages.currentPage().getParameters().get('id');
        String sobjectType = myId.getSObjectType().getDescribe().getName();
        List<Account> accList = new List<Account>();
        Map<String, List<Account>> accMap = new Map<String,List<Account>>();
        xiQIncSF1__xiQ_User_Tokens__c currToken = generateToken();
        
        if (currToken != null) {
            
            if (sobjectType == 'Account') {
                accList = [Select id, name, website from Account where id =: myId ];
                accMap.put(UserInfo.getUserEmail(), accList);
                XiqSync.syncInitialCompanies(accMap,currToken);
                
            } else if (sobjectType == 'Opportunity') {
                accList = [Select id, name, website from Account where id in (Select AccountId from Opportunity where id =: myId)];
                accMap.put(UserInfo.getUserEmail(), accList);
                XiqSync.syncInitialCompanies(accMap,currToken);
                
            }
        }
        
    }
    
}
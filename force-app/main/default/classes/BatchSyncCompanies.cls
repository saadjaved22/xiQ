/*
Author        	| Date             		| Description
Saad Javed       | 1/12/2020  	  | Release 1.1
*/


global without sharing class BatchSyncCompanies implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    
    global xiQIncSF1__xiQ_User_Tokens__c token;
    global Integer totalCount;
    global Integer successCount;
    private Integer usersFailed;
    private Integer usersTotal;
    private Integer usersSuccess;
    private List<xiQIncSF1__xiQ_User_Tokens__c> licensedUsers;
    
    global BatchSyncCompanies(Integer a, Integer b) {
        
        try {
            
            //Data imported from BatchSyncUsers class
            usersSuccess = b;
            usersTotal = a;
            usersFailed = a-b;
            
            totalCount =0;
            successCount = 0;
            
            // Getting Admin's token for use in backend API calls
            ID myID = UserInfo.getUserId();
            token = [SELECT ID, Notify_Email__c, Token__c,User_ID__c FROM xiQIncSF1__xiQ_User_Tokens__c WHERE User_ID__c =: myID];
                      
        } catch(Exception ex) {
            xiQErrorLogger.mailError('BatchSyncCompanies',36,ex.getTypeName(),ex.getMessage());
        }
    }
    
    // Getting all licensed users 
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'Select Notify_Email__c, User_ID__c, isLicensed__c, Token__c FROM xiQIncSF1__xiQ_User_Tokens__c Where Token__c != null'; 
        return Database.getQueryLocator(query);
    }
    
    //Sync accounts from salesforce to XIQ and update XIQ Company ID.
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        try {
            
            Map<String,List<Account>> accountsMap = new Map<String,List<Account>>();
            
            
            //  For every user found in scope, obtains its last 20 modified opportunities or accounts
            //  Constructs a list of these accounts and adds it to a map of key, value pair where
            //  key : licensed User's email
            //  value : List of related Accounts to that user
            //  Passes a list of this map to xiQSync method to obtain company IDs
            //  Constructs a list of all companies found in the HTTP response after casting it into a xiQCompany
            //  Upserts the accounts with populated xiQ_Company_id  
            for (xiQIncSF1__xiQ_User_Tokens__c a : (List<xiQIncSF1__xiQ_User_Tokens__c>) scope) { 
                
                // Get 20 Accounts that have been last modified for every user in list of licensed users
                List<Account> accs = [Select id,Name, Website, LastModifiedBy.Id, LastModifiedDate from Account Where id in (Select AccountId from Opportunity where AccountId != null AND LastModifiedBy.id =: a.User_ID__c ) AND Website !=null ORDER BY LastModifiedDate DESC LIMIT 20] ;
                
                if (accs.size() > 0) {
                    // Get Accounts based on opportunity
                    accountsMap.put(a.Notify_Email__c,accs);
                } else {
                    // Get Accounts based on Accounts obj
                    accs = [Select id,Name, Website, LastModifiedBy.Id, LastModifiedDate from Account Where LastModifiedBy.id =: a.User_Id__c ORDER BY LastModifiedDate DESC LIMIT 20] ;
                    
                    accountsMap.put(a.Notify_Email__c,accs);
                }
            }
            
            if (accountsMap.size() > 0) {
                successCount +=  XiqSync.syncInitialCompanies(accountsMap,token);
            }
            
            totalCount += scope.size();
            
        } catch (Exception ex) {
            xiQErrorLogger.mailError('BatchSyncCompanies',84,ex.getTypeName(),ex.getMessage());
        }
    }
    
    // Sending an email when Syncing of 20 records is completed with the total count, Success and Error count.
    global void finish(Database.BatchableContext BC) {
        
        // Querying current job to check its status later
        AsyncApexJob a = [Select Id, Status, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId() LIMIT 1];
        
        // Querying for all accounts that got a Company ID
        List<Account> acclist = new List<Account>([SELECT ID FROM Account WHERE  XIQ_Company_ID__c != null LIMIT 100 ]);      
        
        // Initiate Messaging service that sends info of successful xiQ Setup run 
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        
        // Email for Admin
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Email for support team
        Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
        
        // Import template and setting addresses.
        EmailTemplate setupComplete = [select id,name,HTMLValue from emailtemplate where name = 'xiQ_SyncCompleteNotification'];
        String body = setupComplete.HTMLValue;
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
        String[] supportTeam = new String[] {'abutt@xiqinc.com','htahir@xiqinc.com','sjaved@xiqinc.com'};
                
        mail.setSubject('Syncing Companies to xiQ ' + a.Status);
        mail2.setSubject('Syncing Companies to xiQ ' + a.Status);
        
        
        // Querying for Licensed Users to build string to be added to the Email body.
        List<User> uList = [SELECT Id,Name FROM User where IsActive = true AND Id in (SELECT UserId FROM UserPackageLicense WHERE (PackageLicense.NamespacePrefix = 'xiQIncSF1'))];
        List<xiQIncSF1__xiQ_User_Tokens__c> licensedUsers = [Select Notify_Email__c FROM xiQIncSF1__xiQ_User_Tokens__c where isLicensed__c = true];
        List<String> licensedEmails = new List<String>();
        
        // String building for Email
        String licensedUsersEmail = '';
        
        for (xiQ_User_Tokens__c user :  licensedUsers) {
            licensedEmails.add(user.Notify_Email__c);
            licensedUsersEmail += user.Notify_Email__c + '<br/>';
        }
        
        // Replacing placeholder text in Email body with dynamic data
        body= body.replace('totalUsers',String.valueOf(usersTotal) );
        body= body.replace('successUsers', String.valueOf(usersSuccess));
        body = body.replace('successUserList',licensedUsersEmail);
        body= body.replace('totalAcc', String.valueOf(totalCount));
        body= body.replace('successAcc', String.valueOf(successCount));
        
        mail.setHtmlBody(body);
        mail2.setHtmlBody(body);
        mail.setToAddresses(toAddresses);
        mail2.setToAddresses(supportTeam);
        
        allMails.add(mail);
        allMails.add(mail2);
        
        // Send Email via Messaging service
        if (allMails.size() > 0) {
            if(Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){
                try {
                    Messaging.sendEmail(allMails); 
                } catch (Exception e) {
                    xiQErrorLogger.mailError('BatchSyncCompanies',149,e.getTypeName(),e.getMessage());                   
                } 
            }
            
        }
    }
}
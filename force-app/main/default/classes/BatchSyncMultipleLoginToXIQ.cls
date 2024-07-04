/*
Author         | Date             | Description
Saad Javed       | 14/10/2020  	  | Release 1.1
*/

@deprecated
global without sharing class BatchSyncMultipleLoginToXIQ implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
  private String sessionId;
  global Integer totalCount;
  global Integer successCount;

  @deprecated
  // Class constructor
  // Initialising total Count of records processed and successful records processed.
  global BatchSyncMultipleLoginToXIQ() {
    /**
        totalCount = 0;
        successCount = 0;
        sessionId = UserInfo.getSessionID();
		**/
  }

  // First two Lists not being used, need to be removed. Cant remove directly.
  // Need to clone this code without declaring the top 2 lists.
  @deprecated
  global List<xiQIncSF1__xiQ_Token__c> userTokenList; //Marked for deletion
  @deprecated
  global List<xiQIncSF1__xiQ_Tokens__c> userToknList; // Marked for deletion
  global List<xiQIncSF1__xiQ_User_Tokens__c> userTokensList;

  //Querying all Active Users
  global Database.QueryLocator start(Database.BatchableContext BC) {
    /**
        Set<String> userEmailSet = new Set<String>();
        Set<String> userIdSet = new Set<String>();
        List<User> uList = new List<User>();
        
        for(xiQIncSF1__xiQ_User_Tokens__c token : [SELECT xiQIncSF1__Notify_Email__c FROM xiQIncSF1__xiQ_User_Tokens__c WHERE xiQIncSF1__Notify_Email__c !=null LIMIT 10000]){
            userEmailSet.add(token.xiQIncSF1__Notify_Email__c);        
        }
                    //System.debug('Line41'+userTokensList);
        
        //System.debug('---------Line 42-------'+userEmailSet.size());
       
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        if (!runningInASandbox) {
            uList = [SELECT Id,Name FROM User where IsActive = true AND Id in (
            SELECT UserId 
            FROM UserPackageLicense 
            WHERE (PackageLicense.NamespacePrefix = 'xiQIncSF1'))];
        }else{
            uList = [SELECT Id,Name FROM User where IsActive = true LIMIT 10000];
        }
            
       
        // un comment above for production, comment below line for production
        //uList = [SELECT Id,Name FROM User  where IsActive = true];
        
        for(User licensedUsers : uList){
            userIdSet.add(licensedUsers.Id);
         //System.debug(userIdSet);
            
        }
        
        // Get list of users with no licenses
        userTokensList = new List<xiQIncSF1__xiQ_User_Tokens__c>();
		**/
    string query = 'Select Id, Name, Email from User WHERE Id IN: userIdSet AND isActive = True LIMIT 10000 ';

    return Database.getQueryLocator(query);
  }

  //Which sync all Active Users from salesforce to XIQ and create the token records.
  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    /**
        try{
            if(scope.size()>0){

                userTokensList = XiqSync.xiqMultipleLogin(UserInfo.getOrganizationId(),sessionId,UserInfo.getUserId(),(List<User>)scope);
            
                if(userTokensList.size()>0){                    
                    database.insert(userTokensList, false);
                                
                    
                    //for (database.SaveResult sr : srList) {
                  
                  //successList.add(sr.getId());
                    //System.debug(successList);
                      //System.debug('Line 103');
                     
                    
                    //}        
                    

                }
            }
            
            
            totalCount += scope.size();
            successCount += scope.size();
            
        } catch (Exception ex) {
            successCount -= scope.size();
        }
		**/
  }

  // Sending an email when Syncing of 20 records is completed with the total count, Success and Error count.
  global void finish(Database.BatchableContext BC) {
    /**
        AsyncApexJob a = [Select Id, Status, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        Database.executeBatch(new BatchSyncCompanies(),20); 
        
        Integer failureCount = totalCount - successCount;
        
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email,'Saad Javed','saad','adeel','hasham'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Syncing Users to xiQ ' + a.Status);
        String emailBody = 'Hello,\r\n\r\n';
        emailBody +='The xiQ for Salesforce package has been installed and has completed batch to sync Users from "Salesforce" to "xiQ".\r\n\r\n';
        emailBody +='Following are the details.\r\n\r\n';
        mail.setPlainTextBody(emailBody+'Total Records processed ' + totalCount +   '\r\nTotal success count '+ successCount);
        allMails.add(mail);
         
        if (allMails.size()>0) {
            
            if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
                try {
                    //Messaging.sendEmail(allMails); 
                } catch (Exception e) {
                                     
                } 
            }
        } 

		**/
  }
}

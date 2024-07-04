/*
Author         | Date             | Description
Saad Javed       | 14/10/2020  	  | Release 1.1
*/

@deprecated
global without sharing class BatchSyncCompaniesToXIQ implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
  @deprecated
  global xiQ_Token__c objToken;
  @deprecated
  global xiQ_Tokens__c objTokn;
  global xiQIncSF1__xiQ_User_Tokens__c token;
  global Integer totalCount;
  global Integer successCount;

  global BatchSyncCompaniesToXIQ() {
    /**
        try{
            totalCount =0;
            successCount = 0;
            ID myID = UserInfo.getUserId();
            User objUser = [SELECT ID,Email FROM User WHERE ID =: myID LIMIT 1];
            token = new xiQIncSF1__xiQ_User_Tokens__c();
            token = [SELECT ID, xiQIncSF1__Notify_Email__c, xiQIncSF1__Token__c,xiQIncSF1__User_ID__c FROM xiQIncSF1__xiQ_User_Tokens__c WHERE xiQIncSF1__Notify_Email__c =:objUser.Email];           
            
        }catch(Exception ex){
            System.debug('Error in line 26');
        }
	**/
  }

  //Querying all Accounts
  global Database.QueryLocator start(Database.BatchableContext BC) {
    string query = 'Select Id, Name, Website from Account WHERE Website != null'; //XIQ_Company_ID__c = null AND
    return Database.getQueryLocator(query);
  }

  //Which sync accounts from salesforce to XIQ and update XIQ Company ID.
  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    /**
        try{
            
            Set<ID> accountIdsSet = new Set<ID>();
            for(Account objAcc : (List<Account>)scope){
                accountIdsSet.add(objAcc.Id);
                System.debug('--------->' + objAcc.id);
            }    
            
            if(scope.size()>0){
               XiqSync.syncCompanies(accountIdsSet,token);          
            }
            
            totalCount +=scope.size();
        }catch (Exception ex) {
            successCount -=scope.size(); 
        }
		**/
  }

  // Sending an email when Syncing of 20 records is completed with the total count, Success and Error count.
  global void finish(Database.BatchableContext BC) {
    /**
        AsyncApexJob a = [Select Id, Status, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId() LIMIT 100];
      
        List<Account> acclist = new List<Account>([SELECT ID FROM Account WHERE  XIQ_Company_ID__c != null LIMIT 100 ]);
        successCount = acclist.size();        
       
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email,'abutt@xiqinc.com','sjaved@xiqinc.com','achaudhary@xiqinc.com','htahir@xiqinc.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Syncing Companies to xiQ ' + a.Status);
        String emailBody = 'Hello,\r\n\r\n';
        emailBody +='The xiQ for Salesforce package has been installed and has completed batch to sync Account from "Salesforce" to "xiQ".\r\n\r\n';
        emailBody +='Following are the details.\r\n\r\n';
        mail.setPlainTextBody(emailBody+'Total Records processed ' + totalCount +   '\r\n Processed Records With xiQ CompanyId '+ successCount);
        allMails.add(mail);
        if(allMails.size()>0){
            if(Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){
                try{
                    Messaging.sendEmail(allMails); 
                }catch(Exception e){
                                       
                } 
            }
                
        }
		**/
  }
}

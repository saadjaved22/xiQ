/*
Author         | Date             | Description    | Last Modified By    | Last Modified Date
Abdullah       | 14/10/2020       | Release 1.1    | Saad                | 07.12.2020
*/


public with sharing class XIQSetupController {
    
    public Boolean showSetupPageLink {get; set;}
    public PackageLicense packageIns {get; set;}
    public String packageID {get; set;}
    public String packageID_s {get; set;}
    
    public Boolean isAdmin {get;set;}
    
    //user Sync status with reason
    public List<xiQIncSF1__xiQ_User_Tokens__c> uList {get; set;}    
    
    //check if current ui is lightning or classic
    public String urlVal {get; set;}  
    public String urlInstance {get; set;}
   
    //account pagination variables
    private integer totalRecs = 0;       
    private integer index = 0;  
    private integer blockSize = 50;
    
    //boolean variables to render users and accounts table
    public boolean showUser {get; set;}
    public boolean showAcc {get; set;}
    
    //Lists to store users and accounts to display in tables 
    public List<User> usersIns {get; set;}
    public List<Account> accIns {get; set;}
    public List<xiQIncSF1__xiQ_User_Tokens__c > userList {get; set;}
    public List<xiQIncSF1__xiQ_User_Tokens__c> licensedUsers;
    public List<Account> membs {get;set;}
    public List<ID> newIds;
    public Integer userRefreshCounter;
    public boolean userRefreshToggle {get;set;}
    public Integer accRefreshCounter;
    public boolean accRefreshToggle {get;set;}
    
    // Variables for progress bar
    private Set<Id> batchClassIds;
    public Boolean isJobs {get;set;}
    public Id batchId {get;set;}
    final public String NOT_START = 'not_started';
    final public String PROCESSING = 'processing';
    final public String FINISHED = 'finished';
    public String message {get;set;}
    public String batchStatus {get;set;}
    public Integer errornum {get;set;}
    public List<AsyncApexJob> jobs;
    public boolean isEnable{get;set;}
    
    
    public XIQSetupController() {
        
        userRefreshCounter = 0;
        accRefreshCounter = 0;
        accRefreshToggle = true;
        userRefreshToggle = true;
        
        toggleLicenseLink();
        refreshUserTable();
        refreshAccountTable();
        
        
        batchClassIds = New Set<Id>();
        
        for(ApexClass objApexClass : [SELECT Name, Id FROM ApexClass WHERE Name='BatchSyncUsers' OR Name='BatchSyncCompanies']){
            batchClassIds.add(objApexClass.Id);
        }
        
        isJobs = true;
        isEnable = false;
        batchStatus = NOT_START;
        message = 'Access Denied: You do not have System Administrator Profile';
        batchId = null; 
        errornum = 0;
        
        String profName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
        if (profName == 'System Administrator') {
            isAdmin = true;
        } else {
            isAdmin = false;
        }
            
        
    }
    
    
    // Method to toggle 'Manage Your Licenses Button'
    public void toggleLicenseLink () {
        packageID = '0000000000000000000000';
        
        urlVal= URL.getSalesforceBaseUrl().toExternalForm();
        urlInstance=urlVal.substringBefore('--');
        
        List<PackageLicense> packageInsList = [Select Id FROM PackageLicense WHERE PackageLicense.NamespacePrefix = 'xiQIncSF1'];
        
        if (packageInsList.size() > 0 ) {
            packageIns = [Select Id FROM PackageLicense WHERE PackageLicense.NamespacePrefix = 'xiQIncSF1' LIMIT 1];
            packageID = packageIns.ID;
            showSetupPageLink = true;    
        } else {
            showSetupPageLink = false;
        }
    }
    
    
    // Get synced users for user table
    public void refreshUserTable() {
        
        if (userRefreshCounter >= 3) {
            userRefreshToggle = false;
            return;
        }
        
        newIds = new List<ID>();
        
        for (xiQIncSF1__xiQ_User_Tokens__c a : [SELECT User_ID__c from xiQIncSF1__xiQ_User_Tokens__c]) {
            ID newID =(ID)a.User_ID__c;
            newIds.add(newID);
        }
        
        usersIns = [select ID,Name from User where ID IN : newIds]; 
        
        uList = new List<xiQIncSF1__xiQ_User_Tokens__c>();
                
        licensedUsers = [select Name,User_ID__c,Notify_Email__c,Reason__c,Token__c from xiQIncSF1__xiQ_User_Tokens__c];
        
        for (xiQIncSF1__xiQ_User_Tokens__c lu: licensedUsers) {
            for (User u: usersIns) {
                if (lu.User_ID__c == u.ID) {
                    lu.Name = u.Name;
                    uList.add(lu);   
                }        
            }
        }
        
        if(uList.size()>0){
            showUser=true;  
        }
        
        userRefreshCounter++;

    }
    
    // Get synced companies for accounts table
    public void refreshAccountTable() {
        
        if (accRefreshCounter >= 3) {
            accRefreshToggle = false;
            return;
        }
        
        totalRecs = [select count() from Account];
        
        accIns = [select XIQ_Company_ID__c from Account where XIQ_Company_ID__c != Null];
        
        if(accIns.size()>0){ 
            
            membs = [SELECT ID,Name,Website, XIQ_Company_ID__c, Type FROM Account ORDER BY CreatedDate DESC LIMIT :blockSize OFFSET :index];  
            showAcc = true;
            
        }
        
        accRefreshCounter++;
    }
    
    // Get synced accounts for account table
    public List<Account> getMemb() { 
        membs = Database.Query('SELECT ID,XIQ_Company_ID__c,Name,Website,CreatedDate, Type FROM Account ORDER BY CreatedDate DESC LIMIT :blockSize OFFSET :index' );  
        return membs;
    }
    
    //Calling Multiple Sync User batch to show/hide section on VF page
    public PageReference callUserBatch(){
        batchId = Database.executeBatch(new BatchSyncUsers(),20);
        isEnable = true;
        batchStatus = PROCESSING;            
        return null;
    }
    
    
    /**
     * Functions to show and update progress bar
     */
    public boolean getShowProgressBar() {
        if(batchStatus == PROCESSING )
            return true;
        return false;
    }
    
    public BatchJob[] getJobs(){
        try{
            
            List<AsyncApexJob> apexJobs = [Select TotalJobItems, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, Id, JobType, ApexClassId, ApexClass.Name, CreatedDate From AsyncApexJob Where ApexClassId IN: batchClassIds  Order by CreatedDate DESC];
            
            if(apexJobs.size() == 0) {
                batchStatus = FINISHED;
                return new List<BatchJob>();
            }
            
            Set<String> jobName = New Set<String>();
            List<BatchJob> jobs = new List<BatchJob>();      
            
            for(AsyncApexJob job : apexJobs) {
                if(!jobName.contains(job.ApexClass.Name)){
                    if(job.Status != 'Completed'){
                        BatchJob objBatchJob = new BatchJob();
                        objBatchJob.isCompleted = false;
                        
                        if(job.Status != 'Completed') {
                            if(job.ApexClass.Name == 'BatchSyncUsers'){
                                objBatchJob.Job_Type = 'Syncing Users';
                                jobName.add(job.ApexClass.Name);
                            }
                            else if(job.ApexClass.Name == 'BatchSyncCompanies'){
                                objBatchJob.Job_Type = 'Syncing Accounts';
                                jobName.add(job.ApexClass.Name);
                            }
                        }            
                        objBatchJob.objAsyncApexJob = job;
                        
                        // NOT START YET
                        if(job.jobItemsProcessed == 0) {
                            objBatchJob.Percent= 0;
                            jobs.add(objBatchJob);
                            continue;
                        }
                        
                        Decimal d = job.jobItemsProcessed;
                        d = d.divide(job.TotalJobItems, 2)*100;
                        objBatchJob.Percent= d.intValue();
                        
                        // PROCESSING
                        if(objBatchJob.Percent != 100){
                            jobs.add(objBatchJob);
                            continue;
                        }
                        
                        
                        errornum += job.NumberOfErrors;
                        objBatchJob.isCompleted = true;
                        jobs.add(objBatchJob); 
                    }
                }
            }
            
            if(jobs.size() == 0){
                batchStatus = FINISHED;
            }
            
            return jobs;
        } catch(exception e) {
            return null;
        }
        
    }
    
    public PageReference updateProgress() {
        if(batchStatus == FINISHED) {
            message = 'COMPLETED';
            isJobs = false;
            isEnable = false;
            showUser= true;
        }
        return null;
    }
    
    
    // Redirection to xiQHome.
    public PageReference xiqHome(){
        PageReference pageRef = new PageReference('/apex/xiQOnline');
        pageRef.setRedirect(true);
        return pageRef;        
    }
 
    
    /**
     * Wrapper class for Batch Job
     */
    public class BatchJob{
        public AsyncApexJob objAsyncApexJob {get;set;}
        public Integer Percent {get;set;}
        public String Job_Type {get;set;}
        public Boolean isCompleted {get;set;}
        public BatchJob(){}     
    }
    
    
    /**
     *  Helper functions for pagination of Accounts table
     */ 
    public void beginning() {   
        index = 0;
    }  
    
    public void previous() {
        index = index - blockSize;
    }  
    
    public void next() {
        index = index + blockSize;  
    }  
    
    public void end() {  
        index = totalrecs - math.mod(totalRecs,blockSize);  
    }          
    
    public boolean getprev() {  
        if(index == 0)  
            return true;
        else  
            return false;
    }    
    
    public boolean getnxt() {  
        if ((index + blockSize) > totalRecs)  
            return true;  
        else  
            return false;
    }
    
}
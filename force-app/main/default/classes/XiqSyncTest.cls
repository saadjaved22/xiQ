/*
Edited By   | Date        | Description
Saad Javed    | 28/9/2020   | Release 2
*/


@isTest (seeAllData = false)
public class XiqSyncTest {
    
    public static testMethod void testInitialSync () {
        String sessionId = UserInfo.getSessionId();
        String OrganizationId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
        
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.website ='www.sap.com';
        insert objAccount;
        
        Opportunity objOpp = new Opportunity(Name='OppName', AccountID=objAccount.ID, CloseDate=System.today(),stageName = 'Closed Won');
        insert objOpp;
        List<Account> accList = new List<Account>();
        accList = [SELECT ID,Name,Website, XIQ_Company_ID__c, Type FROM Account ORDER BY CreatedDate];  
       
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='skhan08@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,isActive = true, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='teststandarduser@test2.com');
        
        insert u;
        userList.add(u);
        
        User insertedUser = [Select id,email from User where Alias = 'standt' LIMIT 1];
        
        // Insert token for backend calls
        xiQIncSF1__xiQ_User_Tokens__c token = new xiQIncSF1__xiQ_User_Tokens__c();
        token.Name = insertedUser.email;
        token.IsLicensed__c= true;
        token.Notify_Email__c = insertedUser.email;
        token.Token__c = '4d2i-def5d8aaf7540aa0a7b6';
        token.User_ID__c = UserInfo.getUserId();
        insert token;
        
        
        
        
        Opportunity opp = [Select id, Name from Opportunity where name ='OppName' LIMIT 1];
        opp.Name = 'OppNameChanged';
        upsert opp;
        
        XIQSetupController objXIQSetupController = new XIQSetupController();
        objXIQSetupController.callUserBatch();
        
        objXIQSetupController.showUser = false;
        objXIQSetupController.showAcc = false;        
        objXIQSetupController.batchStatus = 'finished';
        objXIQSetupController.getShowProgressBar();
        objXIQSetupController.getJobs();
        objXIQSetupController.batchStatus = 'finished';
        objXIQSetupController.updateProgress();
        objXIQSetupController.xiqHome();
        objXIQSetupController.getnxt();
        objXIQSetupController.getprev();
        objXIQSetupController.end();
        objXIQSetupController.next();        
        objXIQSetupController.previous();
        objXIQSetupController.beginning();
        objXIQSetupController.getMemb();

        
        
        Test.stopTest();
        
    }
    
    
    public static testMethod void testSearchControllerwithToken () {
               
        Test.startTest();
        
        // Insert user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='abutt@xiqinc.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,isActive = true, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='teststandarduser@test2.com');
        
        insert u;
        
        User insertedUser = [Select id,email from User where Alias = 'standt' LIMIT 1];
        
        // Insert token for backend calls
        xiQIncSF1__xiQ_User_Tokens__c token = new xiQIncSF1__xiQ_User_Tokens__c();
        token.Name = insertedUser.email;
        token.IsLicensed__c= true;
        token.Notify_Email__c = insertedUser.email;
        token.Token__c = '4d2i-def5d8aaf7540aa0a7b6';
        token.User_ID__c = UserInfo.getUserId();
        insert token;
             
        
        // Account URL building without Company ID
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.website ='www.sap.com';
        insert objAccount;
		        
        PageReference pageRef = Page.xiQAccounts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController accStdCtrlr = new ApexPages.StandardController(objAccount);
        ApexPages.currentPage().getParameters().put('Id',objAccount.id);
        XIQSearchController accController = new XIQSearchController(accStdCtrlr);
        accController.syncCurrCompany();
        
        // Account URL building with Company ID
        Account objAccount1 = new Account();
        objAccount1.Name = 'Test Account';
        objAccount1.website ='www.sap.com';
        objAccount1.XIQ_Company_ID__c = '1';
        insert objAccount1;
		        
        pageRef = Page.xiQAccounts;
        Test.setCurrentPage(pageRef);
        accStdCtrlr = new ApexPages.StandardController(objAccount1);
        ApexPages.currentPage().getParameters().put('Id',objAccount1.id);
        accController = new XIQSearchController(accStdCtrlr);
             
        
        
        // Opportunity URL building
        Opportunity objOpp = new Opportunity(Name='OppName', AccountID=objAccount.ID, CloseDate=System.today(),stageName = 'Closed Won');
        insert objOpp;
        pageRef = Page.xiQOpportunities;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController oppStdCtrlr = new ApexPages.StandardController(objOpp);
        ApexPages.currentPage().getParameters().put('Id',objOpp.id);
        XIQSearchController oppController = new XIQSearchController(oppStdCtrlr);
        oppController.syncCurrCompany();
        
        // Leads URL building for xiQLeads & xiQLeadAnalytics
        Lead objLead = new Lead(LastName='testLeads', Company = 'test', Email = 'test@xiq.com' );
        insert objLead;
        
        // xiQLeads
        pageRef = Page.xiQLeads;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController leadStdCtrlr = new ApexPages.StandardController(objLead);
        ApexPages.currentPage().getParameters().put('Id',objLead.id);
        XIQSearchController leadController = new XIQSearchController(leadStdCtrlr);
        
        // xiQLeadAnalytics
        pageRef = Page.xiQLeadAnalytics;
        Test.setCurrentPage(pageRef);
        leadStdCtrlr = new ApexPages.StandardController(objLead);
        ApexPages.currentPage().getParameters().put('Id',objLead.id);
        leadController = new XIQSearchController(leadStdCtrlr);
        
        // Contact with Company ID URL building for xiQLeads & xiQLeadAnalytics
        Contact objCont = new Contact(LastName='testCon', XIQ_Company_ID__c = '999', email = 'test@xiqinc.com' );
        insert objCont;
        
        // xiQContact
        pageRef = Page.xiQContacts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController contStdCtrlr = new ApexPages.StandardController(objCont);
        ApexPages.currentPage().getParameters().put('Id',objCont.id);
        XIQSearchController contController = new XIQSearchController(contStdCtrlr);
        
        // xiQAnalytics
        pageRef = Page.xiQAnalytics;
        Test.setCurrentPage(pageRef);
        contStdCtrlr = new ApexPages.StandardController(objCont);
        ApexPages.currentPage().getParameters().put('Id',objCont.id);
        contController = new XIQSearchController(contStdCtrlr);
        
        
        // Contact without Company ID but Account ID
        Contact objCont1 = new Contact(FirstName = 'testCon1' ,LastName='testCon', AccountId = objAccount.id );
        insert objCont1;
        
        // xiQContact
        pageRef = Page.xiQContacts;
        Test.setCurrentPage(pageRef);
        contStdCtrlr = new ApexPages.StandardController(objCont1);
        ApexPages.currentPage().getParameters().put('Id',objCont1.id);
        contController = new XIQSearchController(contStdCtrlr);
        
        // Contact without Company ID and Account ID but First Name
        Contact objCont2 = new Contact(FirstName = 'testCon1' ,LastName='testCon' );
        insert objCont2;
        
        // xiQContact
        pageRef = Page.xiQContacts;
        Test.setCurrentPage(pageRef);
        contStdCtrlr = new ApexPages.StandardController(objCont2);
        ApexPages.currentPage().getParameters().put('Id',objCont2.id);
        contController = new XIQSearchController(contStdCtrlr);
        
         // Contact without Company ID and Account ID but First Name
        Contact objCont3 = new Contact(LastName='testCon' );
        
        // xiQContact
        pageRef = Page.xiQContacts;
        Test.setCurrentPage(pageRef);
        contStdCtrlr = new ApexPages.StandardController(objCont3);
        ApexPages.currentPage().getParameters().put('Id',objCont3.id);
        contController = new XIQSearchController(contStdCtrlr);
        
        // Contact without Company ID and Account ID but First Name
        Contact objCont4 = new Contact(LastName='testCon', AccountId = objAccount.id );
        insert objCont4;
        
        // xiQContact
        pageRef = Page.xiQContacts;
        Test.setCurrentPage(pageRef);
        contStdCtrlr = new ApexPages.StandardController(objCont4);
        ApexPages.currentPage().getParameters().put('Id',objCont4.id);
        contController = new XIQSearchController(contStdCtrlr);
        
        // Contact without Company ID and Account ID but First Name
        Contact objCont5 = new Contact(LastName='testCon' );
        insert objCont5;
        
        // xiQContact
        pageRef = Page.xiQContacts;
        Test.setCurrentPage(pageRef);
        contStdCtrlr = new ApexPages.StandardController(objCont5);
        ApexPages.currentPage().getParameters().put('Id',objCont5.id);
        contController = new XIQSearchController(contStdCtrlr);
        
               
        
        
 
        Test.stopTest();
        
        
    }
    
    
    public static testMethod void testSearchControllerwithoutToken () {
        
        Test.startTest();
        
        List<xiQIncSF1__xiQ_User_Tokens__c> tokens = [Select id from xiQIncSF1__xiQ_User_Tokens__c];
        delete tokens;
                
        // Account URL building
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.website ='www.sap.com';
        insert objAccount;
		        
        PageReference pageRef = Page.xiQAccounts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController accStdCtrlr = new ApexPages.StandardController(objAccount);
        ApexPages.currentPage().getParameters().put('Id',objAccount.id);
        XIQSearchController accController = new XIQSearchController(accStdCtrlr);
        accController.syncCurrCompany();
        
 
        Test.stopTest();
        
        
    }
    
    
    public static testMethod void testHomeControllerWithToken () {
        
        Test.startTest();
        
        // Insert user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='abutt@xiqinc.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,isActive = true, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='teststandarduser@test2.com');
        
        insert u;
        
        User insertedUser = [Select id,email from User where Alias = 'standt' LIMIT 1];
        
        // Insert token for backend calls
        xiQIncSF1__xiQ_User_Tokens__c token = new xiQIncSF1__xiQ_User_Tokens__c();
        token.Name = insertedUser.email;
        token.IsLicensed__c= true;
        token.Notify_Email__c = insertedUser.email;
        token.Token__c = '4d2i-def5d8aaf7540aa0a7b6';
        token.User_ID__c = UserInfo.getUserId();
        insert token;
       		        
        PageReference pageRef = Page.xiQNews;
        Test.setCurrentPage(pageRef);
        XIQHomeController homeController = new XIQHomeController();
        homeController.buttonHideShow = true;
        homeController.insertOrUpdateToken();
        
        Test.stopTest();
        
    }
    
    
    public static testMethod void testHomeControllerWithoutTokenField () {
        
        Test.startTest();
        
        // Insert user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='abutt@xiqinc.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,isActive = true, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='teststandarduser@test2.com');
        
        insert u;
        
        User insertedUser = [Select id,email from User where Alias = 'standt' LIMIT 1];
        
        // Insert token for backend calls
        xiQIncSF1__xiQ_User_Tokens__c token = new xiQIncSF1__xiQ_User_Tokens__c();
        token.Name = insertedUser.email;
        token.IsLicensed__c= true;
        token.Notify_Email__c = insertedUser.email;
        token.User_ID__c = UserInfo.getUserId();
        insert token;
       		        
        PageReference pageRef = Page.xiQNews;
        Test.setCurrentPage(pageRef);
        XIQHomeController homeController = new XIQHomeController();
        homeController.buttonHideShow = true;
        homeController.insertOrUpdateToken();
        
        Test.stopTest();
        
    }
    
    
    public static testMethod void testHomeControllerWithoutToken () {
        
        Test.startTest();
        
        List<xiQIncSF1__xiQ_User_Tokens__c> tokens = [Select id from xiQIncSF1__xiQ_User_Tokens__c];
        delete tokens;
        		        
        PageReference pageRef = Page.xiQNews;
        Test.setCurrentPage(pageRef);
        XIQHomeController homeController = new XIQHomeController();
        
        Test.stopTest();
    }
    
    
}
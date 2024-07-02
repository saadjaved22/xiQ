/*
Author         | Date             | Description
Saad Javed       | 14/10/2020       | Release 1.1
*/


public class xiQErrorLogger {
    
    public static void mailError (String className,Integer lineNo, String errType, String errDesc) {
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate errorTemplate = [Select id,name,body from EmailTemplate where name = 'xiQErrorNotification'][0];
        
        String[] toAddresses = new String[] {'abutt@xiqinc.com','sjaved@xiqinc.com','htahir@xiqinc.com'};
        
        mail.setToAddresses(toAddresses);
        mail.setSubject('Error Generated in Org ID: ' + UserInfo.getOrganizationId());
 		
        String emailBody = 'Hi,\r\n\r\nError generated for User : ' + UserInfo.getUsername() + ', Org. ID : ' + UserInfo.getOrganizationId() + '\r\n\r\nError Details:\r\n' + '\r\nClass Name : '+ className + '\r\nLine Number : ' + lineNo + '\r\nError Type : ' + errType + '\r\nError Description : ' + errDesc + '\r\n\r\nThanks,\r\nxiQ for Salesforce';
        mail.setPlainTextBody(emailBody);
        
        allMails.add(mail);
        
        if (allMails.size()>0) {
            
            if(Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){
                try{
                    Messaging.sendEmail(allMails); 
                }catch(Exception e){
                                    
                } 
            }
        }       
    }

   
}
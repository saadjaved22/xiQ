/*
Author         | Date             | Description
Abdullah       | 14/10/2020  	  | Release 1.1
*/


//JSON definition class to create the Request body
public without sharing class XIQCompanyResponseWrapper{
    
    public String status;   //success
    public String message;  //Sync Companies Request processed
    public List<Map<String,cls_companies[]>> companies;
    
    public class cls_companies {
        public String website;  //www.Google.com
        public Integer xiq_company_id;  //0
        public String salesforce_id;    //0011H00001QqUjgQAF
        public String companyName;  //Google
    }
 
}
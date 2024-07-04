/*
Author         | Date             | Description
Saad Javed       | 14/10/2020  	  | Release 1.1
*/

//JSON definition class to create the Request body
public without sharing class XiqCompany {
  public String companyName { get; set; }
  public String website { get; set; }
  public Id salesforce_id { get; set; }
  public String username { get; set; }
  public String token { get; set; }

  public XiqCompany() {
  }
}

/*
Author                      | Date        | Description
Techila Global Services     | 07/02/2018  | Initial Creation of Class
*/

//JSON definition class to Parse the User Response
public without sharing class XiqLoginResponseWrapper {
  public String status; //success
  public String notifyemail; //xiq@techilaservices.com
  public String appName; //SalesForce
  public Integer companiescount; //0
  public Integer industriescount; //0
  public String linkedinusername; //
  public String plan; //-5
  public String twitterusername; //
  public String companiesexist; //False
  public String message; //Login successful
  public String subscription; //Subscribed
  public String token; //axu4-1263374a44d9ebe98a0f
  public String industriesexist; //False
  public String fullname; //xiqtechila
  public String deviceToken; //00D1H000000OfBA!ARgAQDRTZ7_2hpWhK.2AzTiw0HhwuPuQAiZ5oX5qLw4wepjLveMG6gOXDl2M8Lr3Adb_z7sxNpapLXgCXQkw
  public String reason; //reason

  public cls_users[] users;
  public class cls_users {
    public String token; //axu4-1263374a44d9ebe98a0f
    public String name; //xiqtechila
    public String email; //xiq@techilaservices.com
    public String reason;
    public String userId;
  }
}

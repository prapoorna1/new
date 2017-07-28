/******************************************************************************** 
Name:  AccountShareAsyncExecution 
Copyright © 2015  Omnicom Group 
================================================================= 
================================================================= 
This class have logic to add Accounts to Portal Users
=================================================================
================================================================= 
History 
-------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    SOUNDARARAJA A      3/04/2014    INITIAL DEVELOPMENT 
*********************************************************************************/
public class AccountShareAsyncExecution implements Queueable { 
    public void execute(QueueableContext context) {
        List<User> userList=[SELECT id,contactId,IsAccountRecordsAccess__c FROM User WHERE UserType='PowerPartner' and IsAccountRecordsAccess__c=false 
          and contactId!=NULL and IsActive=true];
        list<user> updatedUserList=new list<User>();
        try{
            Map<Id,Id> contactIdUsrIdMap = new Map<Id,Id>();
            for(user u: userList){
                contactIdUsrIdMap.put(u.ContactId,u.Id);
                u.IsAccountRecordsAccess__c=true;
                updatedUserList.add(u); 
            }
            //This method is used to insert acount share for new portal users
            if(contactIdUsrIdMap!=NULL&&contactIdUsrIdMap.size()>0){
                AccountUtilCls.insertAccountShare(contactIdUsrIdMap);
            }
            //This updates portal users with with account access
            if(updatedUserList!=NULL&&updatedUserList.size()>0){
                update updatedUserList;
            }
         }catch(Exception ex){
            System.debug('Portal Users Account Share Failed :: '+ ex.getStackTraceString());
         }          
    }
}
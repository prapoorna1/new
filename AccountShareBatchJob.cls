/******************************************************************************** 
Name:  AccountShareBatchJob
Copyright © 2014  Omnicom Group
================================================================= 
================================================================= 
AccountShareBatchJob
================================================================= 
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL   
1.0-     Tavva              02/01/15      INITIAL DEVELOPMENT             
1.1-     A Soundararaja     02/01/15      INITIAL DEVELOPMENT
*********************************************************************************/ 
global  class AccountShareBatchJob implements database.batchable<sObject>{ 
    global final String query; //changes made by Vijay
    global AccountShareBatchJob(String q)//changes made by Vijay
    {
        query = q;
    }
    //retrieving Portal Users 
    global database.queryLocator start(DataBase.BatchableContext bc){
            string query ='SELECT id,contactId,IsAccountRecordsAccess__c FROM User WHERE UserType=\'PowerPartner\' and IsAccountRecordsAccess__c=false and contactId!=NULL and IsActive=true';
            return Database.getQueryLocator(query);
    }
    //calling account share method to insert account share record for all portal users
    global void execute(Database.BatchableContext BC, List<user> userList){
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
    
    global void finish(Database.BatchableContext BC){
		    // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
		   // Query the AsyncApexJob object to retrieve the current job's information.
		   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
		      TotalJobItems, CreatedBy.Email
		      FROM AsyncApexJob WHERE Id =
		      :BC.getJobId()];
		   // Send an email to the Apex job's submitter notifying of job completion.
		   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		   String[] toAddresses = new String[] {a.CreatedBy.Email};
		   mail.setToAddresses(toAddresses);
		   mail.setSubject('Apex Sharing Recalculation ' + a.Status);
		   mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
		   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
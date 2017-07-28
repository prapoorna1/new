/******************************************************************************** 
Name:  ApexSharing
Copyright © 2015  OmnicCom Group
================================================================= 
================================================================= 
ApexSharing class
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0-     Vijay Ramesh      02/18/15     INITIAL DEVELOPMENT
*********************************************************************************/ 
@isTest
(SeeAllData=true)
public class ApexSharingTest {
    public static testMethod void testApex()
    {
	List<Account> accountList = new List<Account>(); 
        UserRole userRoll = TestUtilities.getUserRole();         
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);        
        insert userRecord;
        User userRecord2 = TestUtilities.getTestUser(userProfile, userRoll);        
        userRecord2.username = 'john6@acme.com';
        insert userRecord2;
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' Limit 1];        
        Account parentAccount = new Account();
        parentAccount.Name = 'Test';
        System.RunAs(userRecord) {
            Insert parentAccount;
        }
        Account accountRecord = TestUtilities.getAccountDetails('TestAccount', parentAccount.Id, recordType.Id, userRecord.Id);
        System.RunAs(userRecord) {
            Insert accountRecord;
        }
        
        Integrated_Project_Folder__c ipf = TestUtilities.getIPFDetails();
        group gg = new group();
        gg.name='name2'; 
        System.RunAs(userRecord){
            insert gg;
        }
        GroupMember gp = new GroupMember(
    	GroupId = gg.Id,
    	UserOrGroupId = userRecord.Id
        );
    	System.RunAs(userRecord){
            insert gp;
        }
        	
            ApexSharing.generateShare('Integrated_Project_Folder__c', ipf.id, gp.UserOrGroupId, 'Read');
            ApexSharing.manualShareAccount(accountRecord.id, gp.UserOrGroupId);
        	
    }
}
/******************************************************************************** 
Name:  AccountAfterInsertTest
Copyright © 2015  OmnicCom Group
================================================================= 
================================================================= 
AccountAfterInsertTest
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0-     Vijay Ramesh      02/17/15     INITIAL DEVELOPMENT
*********************************************************************************/
@isTest
public class AccountAfterInsertTest 
{
    public static testMethod void AccountAfterInsertTesting()
    {
        List<Account> accountList = new List<Account>(); 
        UserRole userRoll = TestUtilities.getUserRole();         
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);        
        
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
    }
    public static testMethod void AccountBeforeDeletetTesting()
    {
        List<Account> accountList = new List<Account>(); 
        UserRole userRoll = TestUtilities.getUserRole();         
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);        
        
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
        System.RunAs(userRecord) {
            Delete accountRecord;
            Undelete accountRecord;
        }
    }
    
    public static testMethod void testgetAccountRemoter()
    {        
        UserRole userRoll = TestUtilities.getUserRole();         
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);    
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' Limit 1];        
        RecordType agencyRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'OMCRepEnt'];
        Account parentAccount = new Account();
        parentAccount.Name = 'Test';
        System.RunAs(userRecord) {
            Insert parentAccount;
        }
        Account accountRecord = TestUtilities.getAccountDetails('TestAccount', parentAccount.Id, agencyRecord.Id, userRecord.Id);
         System.RunAs(userRecord) {
            accountRecord.Type = 'Partner';
            accountRecord.Number_of_Employees__c = '60000';
            accountRecord.Phone = '6666666666';
            Insert accountRecord;
        }        
        AccountRemoter objectReference = new AccountRemoter();      
        AccountRemoter.getAccount(accountRecord.Name);
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestCallout());
        HttpResponse res = AccountRemoter.getSharingBlowoutPage(accountRecord.ParentId);
        Test.stopTest();*/
        AccountRemoter.getSharingBlowoutPage(accountRecord.ParentId);        
    }
}
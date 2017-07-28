@isTest
public class AccountRemoterTest {
    public static testMethod void testgetAccount()
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
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        AccountRemoter.getSharingBlowoutPage(accountRecord.ParentId); 
         
    }
}
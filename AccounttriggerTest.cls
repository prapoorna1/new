@isTest
public class AccounttriggerTest {
	public static testMethod void testblockAccountRemove()
    {        
        List<Account> listIPF = new List<Account>();
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
                Insert accountRecord;
            }        
        System.RunAs(userRecord) {
                Delete accountRecord;
            }
    }
}
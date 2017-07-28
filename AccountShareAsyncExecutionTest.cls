/******************************************************************************** 
Name:  AccountShareAsyncExecutionTest
Copyright © 2015  Omnicom Group
================================================================= 
================================================================= 
This class is used to update job team member notification 
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    VIJAYRAMESH      3/26/2014   INITIAL DEVELOPMENT
 
*********************************************************************************/
@isTest
public class AccountShareAsyncExecutionTest {
	public static testMethod void testingAccountShareAsyncExecution()
    {       
        UserRole userRoll = TestUtilities.getUserRole();         
    	Profile userProfile = TestUtilities.getAdminProfile();
    	User userRecord = TestUtilities.getTestUser(userProfile, userRoll);    
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'ggggg@ggggg.com',
            Alias = 'superman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        System.RunAs(userRecord){
         	Insert portalAccountOwner1;   
        }        
        
        //Create account
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = portalAccountOwner1.Id
        );
        System.RunAs(userRecord){
         	insert portalAccount1;
        }
        //Create contact
        Contact contact1 = new Contact(
            FirstName = 'Test',
                Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@omnicomgroup.com'
        );
        System.RunAs(userRecord){
        	insert contact1;    
        }
        
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Portal User%' Limit 1];
        
        User user1 = new User(     
            Username = System.now().millisecond() + 'test12345@omnicomgroup.com',        
            ContactId = contact1.Id,        
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        System.RunAs(userRecord){
        	Insert user1;    
        }    
        List<User> listuser = new List<User>();
        listuser.add(user1);
        Test.startTest();        
        System.enqueueJob(new AccountShareAsyncExecution ());
        Test.stopTest();        
    }
}
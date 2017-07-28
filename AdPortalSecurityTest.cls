/******************************************************************************** 
Name:  AdPortalSecurityTest
Copyright © 2016  OmnicCom Group
================================================================= 
================================================================= 
Test class for AdPortalSecurity class
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    Sharon Anoop        09/19/2016    INITIAL DEVELOPMENT
*********************************************************************************/
@isTest
private class AdPortalSecurityTest {
    @isTest(SeeAllData=false)  
    public static  void myUnitTest() {
        Map<String,Id> recordMapId=new map<String,Id>(); //creating Map variable
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType]; //fetching all recordtypes from Recordtype object
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);//filtering recordtype with objects and adding with Id.
        }
        Profile p = [select id from profile where name='System Administrator'];
        
        User testUser1 = new User(alias = 'u1', email='u1@testorg.com',
                                  emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid = p.Id, country='United States',
                                  timezonesidkey='America/Los_Angeles', username='test_u1@testorg.com');
        User testUser2 = new User(alias = 'u2', email='u2@testorg.com',
                                 emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p.Id, country='United States',
                                 timezonesidkey='America/Los_Angeles', username='test_u2@testorg.com');
        
        testUser1.UserRoleId=TestUtilities.getUserRole().Id;
        testUser2.UserRoleId=TestUtilities.getUserRole().Id;
        insert testUser1;
        insert testUser2;
        System.runAs(testUser2){
            Integrated_Project_Folder__c ipf = TestUtilities.getIPFDetails();
            insert ipf;
            //inserting records into Account object.
            Account accParent = new account(name='Test');
            insert accParent;
            Account accAgency = new Account();
            accAgency.name='TestAccount';
            accAgency.Member_ID__c = 'check';
            accAgency.Enterprise_ID__c  = 'check';
            accAgency.RecordTypeId=recordMapId.get('Account-OMCRepEnt');
            accAgency.ParentId=accParent.id;
            
            Account accAgencyLegalEntity;
            Account accClientLegalEntity;
            accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),testUser2.id);
            accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),testUser2.id);
            
            insert accAgency;   
            insert accAgencyLegalEntity;
            insert accClientLegalEntity;
            
            //inserting records into Job_Jacket__c object.
            
            Job_Jacket__c job1 = new Job_Jacket__c();
            job1.Job_Jacket_Name__c ='Job 1';
            job1.Agency_of_Record__c = accAgency.id;
            job1.Integrated_Project_Folder__c = ipf.id;
            job1.Production_Lead__c = testUser2.id;
            job1.Biz_Affair_Lead__c = testUser1.id;
            job1.Agency_Managing_Production__c = accAgency.Id;
            job1.Client_Legal_Entity__c = accClientLegalEntity.Id;
            job1.Agency_Legal_Entity__c = accAgencyLegalEntity.Id;
            insert job1;
        
        }
    }
}
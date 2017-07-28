@isTest
public with sharing class ClientSpendReportControllerTest {
    @isTest(SeeAllData=false) 
    public static void testFetchReportValues(){
        
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }
        UserRole userRoll = TestUtilities.getUserRole();                 
        Profile userProfile = TestUtilities.getAdminProfile();      
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);        
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' Limit 1];               
        RecordType agencyRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'OMCRepEnt'];   
        RecordType clientRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'ClientBrand' limit 1];     
        RecordType SeriveCatalogRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Service_Catalog__c' Limit 1];                
        RecordType bidRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName ='Supplier_Bid_Response' AND SObjecttype = 'Bid__c' Limit 1];           
        RecordType biddyRecordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Bid_Line_Item__c' Limit 1];        
        Account parentAccoun = new Account();
        parentAccoun.Name = 'Test';
        System.RunAs(userRecord) {
            Insert parentAccoun;
        }        
        Account accountRecor = TestUtilities.getAccountDetails('TestAccount', parentAccoun.Id, agencyRecord .Id, userRecord.Id);
        Account accountRecor1 = TestUtilities.getAccountDetails('TestAccount', parentAccoun.Id, clientRecord.Id, userRecord.Id);
        Account accountRecor2 = TestUtilities.getAccountDetails('TestAccount', parentAccoun.Id, clientRecord.Id, userRecord.Id);
        System.RunAs(userRecord) {
            accountRecor.Type = 'Partner';
            accountRecor.Number_of_Employees__c = '60000';
            accountRecor.Phone = '6666666666';
            
            Insert accountRecor;
            accountRecor1.Type = 'Partner';
            accountRecor1.Number_of_Employees__c = '60000';
            accountRecor1.Phone = '6666666666';
            accountRecor1.Brand_Client__c=accountRecor.Id;
            Insert accountRecor1;
            accountRecor2.Type = 'Partner';
            accountRecor2.Number_of_Employees__c = '60000';
            accountRecor2.Phone = '6666666666';
            accountRecor2.Brand_Client__c=parentAccoun.Id;
            Insert accountRecor2;
            
        }   
        Integrated_Project_Folder__c ipf = TestUtilities.getIPFDetails();
        System.RunAs(userRecord) {
            insert ipf;
        }
        
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());        
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        System.runAs(userRecord) {
            insert accAgencyLegalEntity;
            insert accClientLegalEntity;    
        }
        
        Job_Jacket__c jjc = TestUtilities.getJobDetail(ipf.Id,accountRecor.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        jjc.Job_Open_Date__c = System.Today();
        jjc.Client_Reporting_Entity__c = accountRecor.Id;
        System.RunAs(userRecord) {
            insert jjc;
        }
        Job_Jacket__c jjg = TestUtilities.getJobDetail(ipf.Id,accountRecor.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        jjg.Job_Open_Date__c = System.Today();
        jjg.Client_Reporting_Entity__c = accountRecor.Id;
        System.RunAs(userRecord) {
            insert jjg;
        }
        
        Job_Jacket__c jjg1 = TestUtilities.getJobDetail(ipf.Id,accountRecor.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        jjg1.Job_Open_Date__c = System.Today();
        jjg1.Client_Reporting_Entity__c = parentAccoun.Id;
        System.RunAs(userRecord) {
            insert jjg1;
        }
        Job_Brand_Product__c jbpc = new Job_Brand_Product__c();
        jbpc.Job_Jacket_ID__c = jjc.id;
        jbpc.Product__c = accountRecor1.id;
        System.RunAs(userRecord){
            insert jbpc;
        }
        Job_Brand_Product__c jbpgc = new Job_Brand_Product__c();
        jbpgc.Job_Jacket_ID__c = jjg.id;
        jbpgc.Product__c = accountRecor1.id;
        System.RunAs(userRecord){
            insert jbpgc;
        }
        
        Service_Catalog__c bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
		bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
		bidResponseTemplate.Template_Type__c = 'Bid Response Form';
		System.RunAs(userRecord){
			insert bidResponseTemplate;
		}
		Service_Catalog__c bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
		bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
		bidRequestTemplate.Template_Type__c = 'Bid Request';
		System.RunAs(userRecord){
			insert bidRequestTemplate;
		}
		Bid__c ggbic = new Bid__c();
        ggbic.Bid_Template__c = bidResponseTemplate.Id;
        ggbic.Bid_Request_Template__c = bidRequestTemplate.Id;
        System.RunAs(userRecord) {
            insert ggbic;
        }
		
        Bid__c bidrecg  = TestUtilities.getCostComponentDetails(jjc.id, bidRequestTemplate.id, bidResponseTemplate.Id ,bidRecordType.Id,ggbic.Id);        
        System.RunAs(userRecord) {
            bidrecg.Bid_Terms_Accepted__c= True;
            insert bidrecg;
        }     
        Bid_Line_Item__c bidlineItem = TestUtilities.getBidLineItemDetails(bidrecg.Id,biddyRecordType.Id,'Summary',null,null,null);
        System.RunAs(userRecord){
            insert bidlineItem;    
        }
        Test.setCurrentPageReference(new PageReference('Page.agencypage'));
        System.currentPageReference().getParameters().put('Id', accountRecor.Id);
        //System.currentPageReference().getParameters().put('Id', parentAccoun.Id);
        String jobName = 'check';
        ClientSpendReportController testRec = new ClientSpendReportController();           
        List<Bid__c> bigist = new List<Bid__c>();
        bigist.add(ggbic);                 
    }    
}
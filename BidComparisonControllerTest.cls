@isTest  
public with sharing class BidComparisonControllerTest {    
    public static testMethod void testfetchAccountList(){   
        
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }     
        //TODO: Hope data will be loaded prior to code deployement if not need to insert dummy record.
        UserRole userRoll = TestUtilities.getUserRole();         
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);    
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' Limit 1];        
        RecordType agencyRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'OMCRepEnt'];
        //RecordType bidRecordtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjecttype = 'Bid__c'AND DeveloperName = 'Supplier_Bid'Limit 1];
        //RecordType bidtemplateRecordtype = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Service_Catalog__c' Limit 1];
        Account parentAccount = new Account();
        parentAccount.Name = 'Test';
        System.RunAs(userRecord) {
            Insert parentAccount;
        }
        Account accountRecord = TestUtilities.getAccountDetails('TestAccount', parentAccount.Id, agencyRecord.Id, userRecord.Id);
        System.RunAs(userRecord) {
            Insert accountRecord;
        }
        EmailTemplate e = TestUtilities.getEmailTemplate();
        System.RunAs(userRecord) {
            Insert e;
        }
        Integrated_Project_Folder__c ipf = TestUtilities.getIPFDetails();
        System.RunAs(userRecord) {
            ipf.OwnerId = userRecord.id;
            Insert ipf;
        }
        
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        System.runAs(userRecord) {
            insert accAgencyLegalEntity;    
            insert accClientLegalEntity;  
        }
        
        Job_Jacket__c job=TestUtilities.getJobDetail(ipf.Id,accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        
        System.RunAs(userRecord) {
            Insert job;            
        }
        
        
        Service_Catalog__c bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
        bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
        bidResponseTemplate.Template_Type__c = 'Bid Response Form';
        
        Service_Catalog__c bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
        bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
        bidRequestTemplate.Template_Type__c = 'Bid Request';
        
        System.RunAs(userRecord) {    
            insert bidResponseTemplate;
            insert bidRequestTemplate;
        }       
        
        
        Bid__c bid6 = TestUtilities.getCostComponentDetails(job.id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'),null);
        System.RunAs(userRecord) {
            Insert bid6;            
        }
        //    Service_Catalog__c bidtemplate = [SELECT Id, Name FROM Service_Catalog__c Limit 1];
        Bid__c bid = TestUtilities.getCostComponentDetails(job.id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'), bid6.id);
        System.RunAs(userRecord) {
            Insert bid;            
        }
        RecordType rectype = [SELECT Id, Name, SObjecttype FROM RecordType WHERE SObjecttype = 'Bid_Line_Item__c' LIMIT 1];
        Bid_Line_Item__c bidlineItem = TestUtilities.getBidLineItemDetails(bid.id,rectype.id,'Summary',null,null,null);
        System.RunAs(userRecord) {
            Insert bidlineItem;            
        }	
        Set<Id> setBid = new Set<Id>();
        List<Bid_Line_Item__c> bidTemplateItems = new List<Bid_Line_Item__c>();
        bidTemplateItems.add(bidlineItem);
        
        for(Bid_Line_Item__c brecord : bidTemplateItems)
        {
            setBid.add(brecord.Bid_ID__c);
        }       
        List<Bid__c> listBids = new List<Bid__c>();
        listBids.add(bid);
        Test.setCurrentPageReference(new PageReference('Page.BidComparePage'));
        System.currentPageReference().getParameters().put('bidId1', bid.Id );                
        BidComparisonController testRec = new BidComparisonController();             
    }    
}
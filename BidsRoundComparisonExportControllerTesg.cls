@isTest
public class BidsRoundComparisonExportControllerTesg { 
    public static testMethod void testingBidsRoundComparisonExportController()
    {   
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        RecordType rctype = [SELECT Id, Name, SObjecttype FROM RecordType WHERE SObjecttype = 'Bid__c' AND Name = 'Supplier Bid Response'];
        RecordType brctype = [SELECT Id, Name, SObjecttype FROM RecordType WHERE SObjecttype = 'Bid_Line_Item__c' Limit 1];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }
        UserRole userRoll = TestUtilities.getUserRole();                 
        Profile userProfile = TestUtilities.getAdminProfile();      
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);        
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' Limit 1];               
        RecordType agencyRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'OMCRepEnt'];        
        RecordType SeriveCatalogRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Service_Catalog__c' Limit 1];                
        RecordType bidRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName ='Supplier_Bid_Response' AND SObjecttype = 'Bid__c' Limit 1];           
        RecordType biddyRecordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Bid_Line_Item__c' Limit 1]; 
        
               
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
        Integrated_Project_Folder__c ipf = TestUtilities.getIPFDetails();
        System.RunAs(userRecord) {
            insert ipf;
        }
        
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),userRecord.Id);
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),userRecord.Id);
        System.RunAs(userRecord) {
            insert accAgencyLegalEntity;
            insert accClientLegalEntity;  
        }
        
        Job_Jacket__c jjc = TestUtilities.getJobDetail(ipf.Id,accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        System.RunAs(userRecord) {
            insert jjc;
        }
        Service_Catalog__c serviceCatalog = TestUtilities.getSeriveCatalogDetails(SeriveCatalogRecord.Id);
        Service_Catalog__c bidResponseTemplate;
        Service_Catalog__c bidRequestTemplate;
        System.RunAs(userRecord) {
          //  insert serviceCatalog;
            
            bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidResponseTemplate.Template_Type__c = 'Bid Response Form';
			insert bidResponseTemplate;
	
		    bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidRequestTemplate.Template_Type__c = 'Bid Request';
			insert bidRequestTemplate;
            
        }
        Bid__c ggbic = new Bid__c();
        ggbic.Bid_Template__c = serviceCatalog.Id;
        System.RunAs(userRecord) {
           // insert ggbic;
        }
        Bid__c bidrecg  = TestUtilities.getCostComponentDetails(jjc.id,bidRequestTemplate.id, bidResponseTemplate.Id,bidRecordType.Id,null);        
        System.RunAs(userRecord) {
            bidrecg.Bid_Terms_Accepted__c= True;
            insert bidrecg;
        }     
        Bid_Line_Item__c bidlineItem = TestUtilities.getBidLineItemDetails(bidrecg.Id,biddyRecordType.Id,'Summary',null,null,null);
        System.RunAs(userRecord){
            insert bidlineItem;    
        }
        Test.setCurrentPageReference(new PageReference('Page.BidComparePage'));
        System.currentPageReference().getParameters().put('bidId', bidrecg.Id);
        //Map<String,String> bidParams = new Map<String,String>();
        //bidParams.put();
        BidsRoundComparisonExportController obj = new  BidsRoundComparisonExportController();
        //obj.xlsHeader();
        //BidsRoundComparisonExportController.xlsHeader cbj = new BidsRoundComparisonExportController.xlsHeader(obj);
    }
}
@isTest
public with sharing class BidRoundComBySupplierTest {    
    public static testMethod void testfetchAccountList(){
        Account acc = new Account ();
        acc.name='testBidAccount';
       insert acc;
              
               
               
        //TODO: Hope data will be loaded prior to code deployement if not need to insert dummy record.
        //Bid__c[] bid = [SELECT Id,Parent_Account_Name__c FROM Bid__c WHERE RecordType.DeveloperName = 'Supplier_Bid' LIMIT 1];
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        //RecordType rctype = [SELECT Id, Name, SObjecttype FROM RecordType WHERE SObjecttype = 'Bid__c' AND Name = 'Supplier Bid'];
        //RecordType brctype = [SELECT Id, Name, SObjecttype FROM RecordType WHERE SObjecttype = 'Bid_Line_Item__c' Limit 1];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }
        //Service_Catalog__c bidTemplate=TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
        //insert bidTemplate;
        
        Service_Catalog__c bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
		bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
		bidResponseTemplate.Template_Type__c = 'Bid Response Form';
		insert bidResponseTemplate;

		Service_Catalog__c bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
		bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
		bidRequestTemplate.Template_Type__c = 'Bid Request';
		insert bidRequestTemplate;
        
        Service_Catalog_Line_Item__c scSubtotalItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Subtotal',null,null,null);
        insert scSubtotalItem;
        Service_Catalog_Line_Item__c scSummaryItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Summary',null,scSubtotalItem.Id,null);
        insert scSummaryItem;
        
        Service_Catalog_Line_Item__c scSectionItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Section',null,scSubtotalItem.Id,null);
        insert scSectionItem;
        Service_Catalog_Line_Item__c scLineItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Line Item',scSummaryItem.Id,null,scSectionItem.Id);
        insert scLineItem;
        Service_Catalog_Line_Item__c scHeaderItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Header',null,null,null);
        insert scHeaderItem;
        Service_Catalog_Line_Item__c scRequirementItem=TestUtilities.getServiceCatalogLineItemDetails(bidRequestTemplate.Id,'Requirement',null,null,null);
        insert scRequirementItem;
        Service_Catalog_Line_Item__c scSpecificationItem=TestUtilities.getServiceCatalogLineItemDetails(bidRequestTemplate.Id,'Specification',null,null,null);
        insert scSpecificationItem;
        Integrated_Project_Folder__c ipf=TestUtilities.getIPFDetails(); 
        insert ipf;
        Account accAgency=TestUtilities.getAccountDetails('test',null,recordMapId.get('Account-OMCRepEnt'),UserInfo.getUserId());
        insert accAgency;
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        insert accAgencyLegalEntity;
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        insert accClientLegalEntity;    
        Job_Jacket__c job=TestUtilities.getJobDetail(ipf.Id,accAgency.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
	    insert job;
        Bid__c costcomponent=TestUtilities.getCostComponentDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'),null);
        insert costcomponent;
        costcomponent.Parent_Account_Name__c = acc.id;
        Bid__c costcomponent1=TestUtilities.getCostComponentDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'),null);
        insert costcomponent1;
        Bid__c bid= TestUtilities.getBidFormDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Bid Form'),costcomponent.Id);
        //bid.RecordTypeId = rctype.id;
        bid.Parent_Bid_Process_Id__c=costcomponent.Id;
        insert bid;
        Bid__c bid1= TestUtilities.getSupplierBidDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Supplier Bid Response'),bid.Id);
		bid1.Parent_Bid_Round__c =bid.id;
        insert bid1;
        Bid__c supplierbid= TestUtilities.getSupplierBidDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Supplier Bid Request'),bid.Id);
        supplierbid.Parent_Bid_Round__c=bid.Id;
        insert supplierbid; 
        
        Test.setCurrentPageReference(new PageReference('Page.BidsRoundComparePage'));
        System.currentPageReference().getParameters().put('bidId', bid1.Id );
        System.currentPageReference().getParameters().put('supId', acc.Id );
        BidRoundComparisonBySupplierController testRec = new BidRoundComparisonBySupplierController();
        
        Bid__c costcomponentq=TestUtilities.getSupplierBidDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Supplier Bid Response'),null);
		costcomponentq.Parent_Bid_Round__c=bid.Id;
        insert costcomponentq;
        Bid__c bidsp=TestUtilities.getSupplierBidDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Supplier Bid Response'),null);       
        bidsp.Parent_Bid_Round__c=bid.Id;
        insert bidsp;
        Bid__c bidsc=TestUtilities.getSupplierBidDetails(job.Id,bidRequestTemplate.Id,bidResponseTemplate.Id,recordMapId.get('Bid__c-Supplier Bid Response'),null);       
        bidsc.Parent_Bid_Round__c=bid.Id;
        bidsc.Is_Invitation_Sent__c = true;
        bidsc.Parent_Account_Name__c = acc.id;
        insert bidsc;
        Bid_Line_Item__c bidlineItem = TestUtilities.getBidLineItemDetailcs(bidsc.Id,recordMapId.get('Bid_Line_Item__c-Bid Form Item'),'Summary',null,null,null);
        insert bidlineItem;
        //Bid__c bidSystem = [SELECT Id, Name FROM Bid__c WHERE Id = 'a0EJ000000GJcfs'];
        //Account accSystem = [SELECT Id, Name FROM Account WHERE Id = '001J000001Uhi5rIAB'];
        Test.setCurrentPageReference(new PageReference('Page.BidsRoundComparePage'));
        System.currentPageReference().getParameters().put('bidId', bid1.Id );
        System.currentPageReference().getParameters().put('supId', acc.Id );
        /*Test.setCurrentPageReference(new PageReference('Page.BidsRoundComparePage'));
        System.currentPageReference().getParameters().put('bidId', bidsc.Id );
        System.currentPageReference().getParameters().put('supId', accAgency.Id );*/
        
        Test.startTest();
        BidRoundComparisonBySupplierController testRec2 = new BidRoundComparisonBySupplierController();
        Test.stopTest();
       // testRec.fetchAccountList();
        
    }
}
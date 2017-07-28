@isTest
public class BidComparisonBySupplyerControllerTest {
    public static testMethod void testingBidComparisonBySupplyerController() {
        
        recordType rc = new recordType();
        rc = [SELECT ID, Name, DeveloperName From RecordType where DeveloperName = : 'Supplier_Bid_Response'];
        
        Map < String, Id > recordMapId = new map < String, Id > ();
        List < RecordType > recordTypeList = [Select Id, Name, SobjectType from RecordType];
        for (RecordType recordType: recordTypeList) {
            recordMapId.put(recordType.SobjectType + '-' + recordType.Name, recordType.Id);
        }
        
        UserRole userRoll = TestUtilities.getUserRole();
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);
        Insert userRecord;
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account'
                                 Limit 1
                                ];
        RecordType agencyRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account'
                                   AND Name = 'OMCRepEnt'
                                  ];
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
            Insert ipf;
        }
        
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),userRecord.Id);
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),userRecord.Id);
        System.RunAs(userRecord) {
            insert accAgencyLegalEntity;
            insert accClientLegalEntity;
        }
        
        Job_Jacket__c jjc=TestUtilities.getJobDetail(ipf.Id,accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        
        System.RunAs(userRecord) {
            Insert jjc;
        }
        Job_Asset__c jac = TestUtilities.getDeliverableDetails();
        System.RunAs(userRecord) {
            Insert jac;
        }
        Job_Jacket_Deliverable__c jbc = TestUtilities.getJobJacketDeliverables(jjc.id, jac.id);
        System.RunAs(userRecord) {
            Insert jbc;
        }
        
       
        Job_Jacket__c job=TestUtilities.getJobDetail(ipf.Id,accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        System.RunAs(userRecord) {
            Insert job;
        }
        Service_Catalog__c bidTemplate1 = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
        
        Service_Catalog__c bidResponseTemplate;
        Service_Catalog__c bidRequestTemplate;
        System.RunAs(userRecord) {
            //insert bidTemplate1;
            
             bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidResponseTemplate.Template_Type__c = 'Bid Response Form';
			insert bidResponseTemplate;
	
		    bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidRequestTemplate.Template_Type__c = 'Bid Request';
			insert bidRequestTemplate;
        }
        Bid__c costcomponent = TestUtilities.getCostComponentDetails(job.Id,  bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Cost Component'), null);
        costcomponent.Bid_Round_Status__c = OmnicomConstant.BID_ROUND_STATUS_SETTING_UP;
        System.RunAs(userRecord) {
            insert costcomponent;
        }
        Bid__c bid = TestUtilities.getBidFormDetails(job.Id,  bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Bid Form'), costcomponent.Id);
        bid.Bid_Round_Status__c = OmnicomConstant.BID_ROUND_STATUS_SETTING_UP;
        System.RunAs(userRecord) {
            insert bid;
        }
        
        Bid__c bd = new Bid__c();
        bd.Component_Name__c = 'bidComponent';
        bd.Parent_Account_Name__c = accountRecord.id;
        bd.RecordTypeId = rc.id;
        bd.Bidding_Round__c = 1;
        bd.Bid_Round_Status__C = 'Setting Up';
        bd.Supplier_Bid_Request_Status__c = 'Producer Drafting';
        bd.Due_date__c = Date.valueOf('2015-04-15');
        bd.Component_Name__c = 'TestComponent';
        bd.Bid_Template__c = bidResponseTemplate.Id;
        bd.Bid_Request_Template__c=bidRequestTemplate.id;
        bd.Is_Invitation_Sent__c = true;
        bd.Parent_Bid_Round__c = bid.id;
        System.RunAs(userRecord) {
            insert bd;
        }
        
        Bid__c bd1 = new Bid__c();
        bd1.Component_Name__c = 'bidComponent';
        bd1.Parent_Account_Name__c = accountRecord.id;
        bd1.Bid_Template__c = bidResponseTemplate.Id;
        bd1.Bid_Request_Template__c=bidRequestTemplate.id;
        bd1.Parent_Bid_Round__c = bid.id;
        bd1.RecordTypeId = rc.id;
        bd1.Bidding_Round__c = 1;
        bd1.Bid_Round_Status__C = 'Setting Up';
        bd1.Supplier_Bid_Request_Status__c = 'Producer Drafting';
        bd1.Due_date__c = Date.valueOf('2015-04-15');
        bd1.Component_Name__c = 'TestComponent';
        bd1.Is_Invitation_Sent__c = true;
        System.RunAs(userRecord) {
            insert bd1;
        }
        //TODO: Hope data will be loaded prior to code deployement if not need to insert dummy record.
        //Bid__c[] bid = [SELECT Id,Parent_Account_Name__c FROM Bid__c WHERE RecordType.DeveloperName = 'Supplier_Bid' LIMIT 1];
        
        Test.starttest();
        RecordType rctype = [SELECT Id, Name, SObjecttype FROM RecordType WHERE SObjecttype = 'Bid__c'
                             AND Name = 'Supplier Bid Response'
                            ];
        RecordType brctype = [SELECT Id, Name, SObjecttype FROM RecordType WHERE SObjecttype = 'Bid_Line_Item__c'
                              Limit 1
                             ];
        Service_Catalog__c bidTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
        System.RunAs(userRecord) {
            //insert bidTemplate;
        }
        Service_Catalog_Line_Item__c scSubtotalItem = TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id, 'Subtotal', null, null, null);
        System.RunAs(userRecord) {
            insert scSubtotalItem;
        }
        Service_Catalog_Line_Item__c scSummaryItem = TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id, 'Summary', null, scSubtotalItem.Id, null);
        System.RunAs(userRecord) {
            insert scSummaryItem;
        }
        
        Service_Catalog_Line_Item__c scSectionItem = TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id, 'Section', null, scSubtotalItem.Id, null);
        System.RunAs(userRecord) {
            insert scSectionItem;
        }
        Service_Catalog_Line_Item__c scLineItem = TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id, 'Line Item', scSummaryItem.Id, null, scSectionItem.Id);
        System.RunAs(userRecord) {
            insert scLineItem;
        }
        Service_Catalog_Line_Item__c scHeaderItem = TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id, 'Header', null, null, null);
        System.RunAs(userRecord) {
            insert scHeaderItem;
        }
        Service_Catalog_Line_Item__c scRequirementItem = TestUtilities.getServiceCatalogLineItemDetails(bidRequestTemplate.Id, 'Requirement', null, null, null);
        System.RunAs(userRecord) {
            insert scRequirementItem;
        }
        Service_Catalog_Line_Item__c scSpecificationItem = TestUtilities.getServiceCatalogLineItemDetails(bidRequestTemplate.Id, 'Specification', null, null, null);
        System.RunAs(userRecord) {
            insert scSpecificationItem;
        }
        costcomponent.Parent_Account_Name__c = accountRecord.id;
        
        Bid__c bid2 = TestUtilities.getBidFormDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Bid Form'), costcomponent.Id);
        bid2.Parent_Bid_Process_Id__c = costcomponent.Id;
        System.RunAs(userRecord) {
            insert bid2;
        }
        Bid__c bid1 = TestUtilities.getSupplierBidDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Supplier Bid Response'), bid2.Id);
        bid1.Parent_Bid_Round__c = bid2.id;
        System.RunAs(userRecord) {
            insert bid1;
        }
        Bid__c supplierbid = TestUtilities.getSupplierBidDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Supplier Bid Response'), bid2.Id);
        supplierbid.Parent_Bid_Round__c = bid2.Id;
        System.RunAs(userRecord) {
            insert supplierbid;
        }
        Test.setCurrentPageReference(new PageReference('Page.BidsRoundComparePage'));
        System.currentPageReference().getParameters().put('bidId', costcomponent.Id);
        System.currentPageReference().getParameters().put('supId', accountRecord.Id);
        BidsRoundComparisonController testRec = new BidsRoundComparisonController();
        
        Bid__c costcomponentq = TestUtilities.getSupplierBidDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Supplier Bid Response'), null);
        costcomponentq.Parent_Bid_Round__c = bid2.Id;
        System.RunAs(userRecord) {
            insert costcomponentq;
        }
        Bid__c bidsp = TestUtilities.getSupplierBidDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Supplier Bid Response'), null);
        bidsp.Parent_Bid_Round__c = bid2.Id;
        System.RunAs(userRecord) {
            insert bidsp;
        }
        Bid__c bidsc = TestUtilities.getSupplierBidDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id, recordMapId.get('Bid__c-Supplier Bid Response'), null);
        bidsc.Parent_Bid_Round__c = bid2.Id;
        bidsc.Is_Invitation_Sent__c = true;
        bidsc.Parent_Account_Name__c = accountRecord.id;
        System.RunAs(userRecord) {
            insert bidsc;
        }
        Bid_Line_Item__c bidlineItem = TestUtilities.getBidLineItemDetailcs(bidsc.Id, brctype.Id, 'Line Item', null, null, null);
        System.RunAs(userRecord) {
            insert bidlineItem;
        }
        //Bid__c bidSystem = [SELECT Id, Name FROM Bid__c WHERE Id = 'a0EJ000000GJcfs'];
        //Account accSystem = [SELECT Id, Name FROM Account WHERE Id = '001J000001Uhi5rIAB'];
        Test.setCurrentPageReference(new PageReference('Page.BidsRoundComparePage'));
        System.currentPageReference().getParameters().put('bidId', costcomponentq.Id);
        System.currentPageReference().getParameters().put('supId', accountRecord.Id);
        /*Test.setCurrentPageReference(new PageReference('Page.BidsRoundComparePage'));
System.currentPageReference().getParameters().put('bidId', bidsc.Id );
System.currentPageReference().getParameters().put('supId', accAgency.Id );*/
        BidComparisonBySupplyerController bcbsc = new BidComparisonBySupplyerController();
        //bcbsc.fetchAccountList();
        
        Test.stoptest();
    }
}
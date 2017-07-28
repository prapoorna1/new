@isTest(SeeAllData=false) 
public class AttachUtilTest {	
	public static testMethod void AttachUtilTest(){
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }
        Profile p = [select id from profile where name='System Administrator'];        
        User userRecord = new User(alias = 'u1', email='u1@testorg.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p.Id, country='United States',
                                 timezonesidkey='America/Los_Angeles', username='test_g1@testorg.com');
         userRecord.UserRoleId=TestUtilities.getUserRole().Id; 
       // Insert userRecord;
        set<Id> accountIdList=new set<Id>();
        //Case 1:
        Account accSupplier=TestUtilities.getAccountDetails('test',null,recordMapId.get('Account-SupplierRepEnt'),UserInfo.getUserId());
        //System.RunAs(userRecord){
         	insert accSupplier;   
        //}        
        Account accSupplier1=TestUtilities.getAccountDetails('test1',null,recordMapId.get('Account-SupplierRepEnt'),UserInfo.getUserId());
       // System.RunAs(userRecord){
         	insert accSupplier1; 
       // }         
        accountIdList.add(accSupplier.Id);
        accountIdList.add(accSupplier1.Id);
        AccountUtilCls.updateSupplierMetrics(accountIdList);
        
        
        Service_Catalog__c bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
		bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
		bidResponseTemplate.Template_Type__c = 'Bid Response Form';
		insert bidResponseTemplate;
		
		Service_Catalog__c bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
		bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
		bidRequestTemplate.Template_Type__c = 'Bid Request';
		insert bidRequestTemplate;
        
        //Case 2:
       // Service_Catalog__c bidResponseTemplate=TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
       // System.RunAs(userRecord){
         //	insert bidResponseTemplate;
      //  }         
        Service_Catalog_Line_Item__c scSubtotalItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Subtotal',null,null,null);
      //  System.RunAs(userRecord){
         	insert scSubtotalItem;
      //  }          
        Service_Catalog_Line_Item__c scSummaryItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Summary',null,scSubtotalItem.Id,null);
      //  System.RunAs(userRecord){
         	insert scSummaryItem;
      //  }
        Service_Catalog_Line_Item__c scSectionItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Section',null,scSubtotalItem.Id,null);
      //  System.RunAs(userRecord){
         	insert scSectionItem;
      //  }        
        Service_Catalog_Line_Item__c scLineItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Line Item',scSummaryItem.Id,null,scSectionItem.Id);
      //  System.RunAs(userRecord){
         	insert scLineItem;
      //  }        
        Service_Catalog_Line_Item__c scHeaderItem=TestUtilities.getServiceCatalogLineItemDetails(bidResponseTemplate.Id,'Header',null,null,null);
       // System.RunAs(userRecord){
         	insert scHeaderItem;
      //  }
        Service_Catalog_Line_Item__c scRequirementItem=TestUtilities.getServiceCatalogLineItemDetails(bidRequestTemplate.Id,'Requirement',null,null,null);
     //   System.RunAs(userRecord){
         	insert scRequirementItem;
      //  }
        Service_Catalog_Line_Item__c scSpecificationItem=TestUtilities.getServiceCatalogLineItemDetails(bidRequestTemplate.Id,'Specification',null,null,null);
      //  System.RunAs(userRecord){
         	insert scSpecificationItem;
      //  }        
        Integrated_Project_Folder__c ipf=TestUtilities.getIPFDetails(); 
       // System.RunAs(userRecord){
         	insert ipf;
      //  }        
        Account accAgency=TestUtilities.getAccountDetails('test',null,recordMapId.get('Account-OMCRepEnt'),UserInfo.getUserId());
      //  System.RunAs(userRecord){
        	insert accAgency;
        
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        insert accAgencyLegalEntity;
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        insert accClientLegalEntity;    
        Account accSupplierLegalEntity=TestUtilities.getAccountSupplierLegalEntityDetails('SLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        insert accSupplierLegalEntity;
        
        Job_Jacket__c job=TestUtilities.getJobDetail(ipf.Id,accAgency.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        job.Job_Jacket_Status__c='Open';
        job.Job_Jacket_Stage__c='Production (4 of 7)';
        insert job;
        
        
        Bid__c costComponent= TestUtilities.getCostComponentDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'),null);        
		costComponent.Awarded_Supplier__c=accSupplier.Id;
		costcomponent.Awarded_Supplier_Legal_Entity__c = accSupplierLegalEntity.id;
		costComponent.Cost_Component_Status__c='Awarding';
        insert costComponent;
        
        Bid__c costComponent5= TestUtilities.getCostComponentDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'),null);
		costComponent5.Cost_Component_Status__c='Sourcing';        
        insert costComponent5;
        Bid__c bid= TestUtilities.getBidFormDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id,recordMapId.get('Bid__c-Bid Form'),null);
        bid.Parent_Bid_Process_Id__c=costComponent5.Id;
        insert bid;
        
        Bid__c supplierbid= TestUtilities.getSupplierBidDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id,recordMapId.get('Bid__c-Supplier Bid Response'),null);
        supplierbid.Parent_Account_Name__c=accSupplier.Id;
        supplierbid.Supplier_Bid_Response_Status__c='Submitted';
        supplierbid.Parent_Bid_Round__c=bid.Id;        
        insert supplierbid;
        
        
        Attachment attach = new Attachment();
        attach.ParentId = bid.id;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.Name = 'utilAttach';
        insert attach;
        Attachment ag = new Attachment();
        ag.ParentId = supplierbid.id;
        Blob gg=Blob.valueOf('Unit Test Attachment Body');
        ag.body=bodyBlob;
        ag.Name = 'utilAttach';
        insert ag;
        Attachment attachs = new Attachment();
        attachs.ParentId = job.id;
        Blob gl=Blob.valueOf('Unit Test Attachment Body');
        attachs.body=gl;
        attachs.Name = 'utilAttach';
        insert attachs;
        map<Id,list<Attachment>> attachmentMap=new map<Id,list<Attachment>>();        
        List<Attachment> lisAttachs = new List<Attachment>();
        List<Attachment> lisAttachg = new List<Attachment>();
        lisAttachs.add(attach);
        lisAttachs.add(attachs);
        lisAttachg.add(ag);
        AttachUtil.AttachBid(lisAttachs);
        AttachUtil.changeInternal(lisAttachs);
        attachmentMap.put(ag.ParentId,lisAttachg);
        AttachUtil.validateAttachmentDelete(attachmentMap);
        map<Id,set<Id>> jobBidMap =  new map<Id,set<Id>>();
        set<Id> setId = new set<Id>();
        setId.add(supplierbid.id);
        jobBidMap.put(job.id, setId);
        AttachUtil.AttachJob(lisAttachg,jobBidMap,setId);
      // }
	}
}
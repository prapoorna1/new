/******************************************************************************** 
Name:  BidLineItemUtilClsTest
Copyright © 2014  OmnicCom Group
================================================================= 
================================================================= 
Test class for BidLineItemUtilClsTest class
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    Nagesh.K.R          10/17/2014    INITIAL DEVELOPMENT
1.0 -    A Soundararaja      11/20/2014   
*********************************************************************************/
@isTest
public class BidLineItemUtilClsTest{

    @isTest public static void testUpdateLineItemTotal(){
        List<Bid_Line_Item__c> bidLineItemList = new List<Bid_Line_Item__c>();
        
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }
    
        /* List <recordtype> bidTempRecIdList = [select id from recordtype where name = 'Bid Template' and SobjectType = 'Service_Catalog__c'];
        Id bidTempRecId;
        if(bidTempRecIdList.size()>0)
        {
            bidTempRecId=bidTempRecIdList[0].Id;        
        } 
        
        List <recordtype> costComponentRecIdList = [select id from recordtype where name = 'Cost Component' and SobjectType = 'Bid__c'];
        Id costComponentRecId;
        if(costComponentRecIdList.size()>0)
        {
            costComponentRecId=costComponentRecIdList[0].Id;        
        } 
        
        Id BidLineItemRecTypeId = [select id from recordtype where name = 'Bid Line Item' and SobjectType = 'Bid_Line_Item__c'].id;
        Id BidFormItemRecTypeId = [select id from recordtype where name = 'Bid Form Item' and SobjectType = 'Bid_Line_Item__c'].id;       
        */
        Id BidFormItemRecTypeId = recordMapId.get('Bid_Line_Item__c-Bid Form Item');
        
        Service_Catalog__c servCatlog = new Service_Catalog__c();
        //servCatlog.RecordTypeId = bidTempRecId;
        servCatlog.RecordTypeId = recordMapId.get('Service_Catalog__c-Bid Template');
        //insert servCatlog;
        
        
		
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
        Account accOmnicomSupplier=TestUtilities.getAccountDetails('test1',null,recordMapId.get('Account-SupplierRepEnt'),UserInfo.getUserId());
        insert accOmnicomSupplier;
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        insert accAgencyLegalEntity;
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        insert accClientLegalEntity;    
        Job_Jacket__c job=TestUtilities.getJobDetail(ipf.Id,accAgency.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        insert job;
        
        
        Bid__C costComp =TestUtilities.getCostComponentDetails(job.Id, bidRequestTemplate.id, bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'),null);
        //costComp.RecordTypeId = costComponentRecId;
       // costComp.RecordTypeId = recordMapId.get('Bid__c-Cost Component');
        //costComp.Bid_Template__c = bidResponseTemplate.id ;
        insert costComp;
        
       // Id costCompId = [Select Id from Bid__C limit 1].Id;
        Id costCompId = costComp.id;

        
        //Section
        Bid_Line_Item__c bidLineItemSection = new Bid_Line_Item__c();
        bidLineItemSection.Type__c = 'Section';
        bidLineItemSection.Bid_ID__c = costCompId;
        bidLineItemSection.RecordTypeId = BidFormItemRecTypeId;
        bidLineItemSection.Item_Code__c='13';
         
        bidLineItemList.add(bidLineItemSection);
        
        //Summary
        Bid_Line_Item__c bidLineItemSummary = new Bid_Line_Item__c();
        bidLineItemSummary.Type__c = 'Summary';
        bidLineItemSummary.Bid_ID__c = costCompId;
        bidLineItemSummary.RecordTypeId = BidFormItemRecTypeId;
        bidLineItemSummary.Item_Code__c='12';
             
        bidLineItemList.add(bidLineItemSummary);
                
        ID bidLineItemSecId = bidLineItemSection.id;    
        ID bidLineItemSumId = bidLineItemSummary.id;
        
        //Line Item
        Bid_Line_Item__c bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Rate__c = 25;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.Quantity__c = 100;
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='11';
        bidLineItemList.add(bidLineItem);

        //Line Item
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        // bidLineItem.RecordTypeId = BidLineItemRecTypeId;
        bidLineItem.RecordTypeId = recordMapId.get('Bid_Line_Item__c-Bid Line Item');
        bidLineItem.Item_Code__c='10';
        bidLineItemList.add(bidLineItem);
        
        //Line Item - Extended Amount
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='Extended Amount';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='9';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);

                
        //Line Item - Simple Amount
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='Simple Amount';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='8';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);
        
        //Line Item - Percentage Amount
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='Percentage Amount';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='7';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);
        
        //Line Item - Date
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='Date';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='6';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);

        //Line Item - Text
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='Text';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='5';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);

        //Line Item - Rich Text
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='Rich Text';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='4';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);

        //Line Item - True/False
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='True/False';
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='3';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);

        //Line Item - Number
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Data_Type__c='Number';
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='2';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);
        
        //Line Item - Picklist
        bidLineItem = new Bid_Line_Item__c();
        bidLineItem.Type__c = 'Line Item';
        bidLineItem.Bid_ID__c = costCompId;
        bidLineItem.Data_Type__c='Picklist';
        bidLineItem.Is_Required__c = TRUE;
        bidLineItem.Section__c = bidLineItemSecId;
        bidLineItem.Summary__c = bidLineItemSumId;
        bidLineItem.RecordTypeId = BidFormItemRecTypeId;
        bidLineItem.Item_Code__c='1';
        bidLineItem.Name__c='test';
        bidLineItemList.add(bidLineItem);
        Insert bidLineItemList;
        
       // List<Bid_Line_Item__c> bidLineItemList = [Select Id, Type__c,Data_Type__c,Rate__c, Is_Required__c ,Summary__c ,Quantity__c, Section__c,SubTotal__c, RecordTypeId from Bid_Line_Item__c];
        update bidLineItemList[0];
        delete bidLineItemList[0];
        undelete bidLineItemList[0];
        
        BidLineItemUtilCls.updateLineItemTotal(bidLineItemList);
        BidLineItemUtilCls.updateBidLineItemTotal(bidLineItemList);
        BidLineItemUtilCls.validateBidLineItem(bidLineItemList);
        BidLineItemUtilCls.deleteSectionBidLineItem(bidLineItemList);
        
        
    }
}
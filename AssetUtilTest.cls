/*************************************************************************************** 
Name:  AssetUtilTest class 
Copyright © 2015  Omnicom Group Inc.
================================================================= 
================================================================= 
This class is used to test asset related funcationality and 
to test whether the asset is getting updated.
=================================================================
================================================================= 
History  
-------
VERSION  AUTHOR              DATE         DETAIL                

1.0 -    Chandana M         2/9/2015   
*****************************************************************************************/
@isTest
public without sharing  class AssetUtilTest{
    @isTest
    private static void test_updateBidAssetDetails(){
        
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }
        UserRole userRoll = TestUtilities.getUserRole();         
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);    
        Insert userRecord;
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' Limit 1];        
        RecordType agencyRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'OMCRepEnt'];
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
        
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        System.RunAs(userRecord) {
            insert accAgencyLegalEntity;
            insert accClientLegalEntity;    
        }
        
        Job_Jacket__c jjc = TestUtilities.getJobDetail(ipf.Id,accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        System.RunAs(userRecord)        {
            Insert jjc;
        }
        Job_Asset__c jac = TestUtilities.getDeliverableDetails();
        System.RunAs(userRecord){
            Insert jac;
        }
        Job_Asset__c jac1 = TestUtilities.getDeliverableDetails();
        System.RunAs(userRecord){
            Insert jac1;
            delete jac1;
            undelete jac1;
        }
        Job_Jacket_Deliverable__c jbc = TestUtilities.getJobJacketDeliverables(jjc.id, jac.id);
        System.RunAs(userRecord){
            Insert jbc;
        }
        Job_Jacket__c job = TestUtilities.getJobDetail(ipf.Id,accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        System.RunAs(userRecord) {
            Insert job;
        }
        Service_Catalog__c bidResponseTemplate;
        Service_Catalog__c bidRequestTemplate ;
        Service_Catalog__c bidTemplate=TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
        System.RunAs(userRecord) {
            //insert bidTemplate;
            bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidResponseTemplate.Template_Type__c = 'Bid Response Form';
			insert bidResponseTemplate;
	
		    bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidRequestTemplate.Template_Type__c = 'Bid Request';
			insert bidRequestTemplate;
        }
        Bid__c costcomponent=TestUtilities.getCostComponentDetails(job.Id,bidRequestTemplate.id, bidResponseTemplate.Id,recordMapId.get('Bid__c-Cost Component'),null);
        costcomponent.Bid_Round_Status__c=OmnicomConstant.BID_ROUND_STATUS_SETTING_UP;
        System.RunAs(userRecord) {
            insert costcomponent;
        }
        Bid__c bid= TestUtilities.getBidFormDetails(job.Id,bidRequestTemplate.id, bidResponseTemplate.Id,recordMapId.get('Bid__c-Bid Form'),costcomponent.Id);
        bid.Bid_Round_Status__c=OmnicomConstant.BID_ROUND_STATUS_SETTING_UP;
        System.RunAs(userRecord) {
            insert bid;
        }
        OPS_Asset__c asset=TestUtilities.getAssetDetails(jac.Id);
        System.RunAs(userRecord) {
            insert asset;
        }
        Bid_Asset__c bac = TestUtilities.getBidAsset(bid.Id,asset.Id);
        System.RunAs(userRecord) {
            Insert bac;
        }
        list<Bid_Asset__c> updatedBidAssetList=new list<Bid_Asset__c>();
        updatedBidAssetList.add(bac);
        map<Id,OPS_Asset__c > assetMap = new map<Id,OPS_Asset__c >();
        assetMap.put(asset.id,asset);
        System.RunAs(userRecord)
        {
            AssetUtil.updateBidAssetDetails(assetMap); 
        }           
    }
}
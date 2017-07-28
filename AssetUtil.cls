/*************************************************************************************** 
Name:  AssetUtil class 
Copyright © 2015  Omnicom Group Inc.
================================================================= 
================================================================= 
This class is used contain asset related funcationality and updateBidAssetDetails
 method is used to update the Bid Asset whenever asset is getting updated
=================================================================
================================================================= 
History  
-------
VERSION  AUTHOR              DATE         DETAIL                

1.0 -    Soundararaja A      8/2/2015    
*****************************************************************************************/
public without sharing class AssetUtil{
    
 /*******************************************************************
    Purpose     :  updateBidAssetDetails method is used to update the Bid Asset whenever asset is getting updated
    Parameters  : assetMap-map<Id,OPS_Asset__c >  of OPS_Asset__c
    Returns     : void
    ********************************************************************/
 public static void updateBidAssetDetails(map<Id,OPS_Asset__c > assetMap){
    
   list<Bid_Asset__c> updatedBidAssetList=new list<Bid_Asset__c>();
   list<Bid_Asset__c> bidAssetList=[select Asset_ID__c from Bid_Asset__c where Bid_ID__r.isLocked__c=false and  Asset_ID__c!=NULL and Asset_ID__c=:assetMap.keySet() and 
   ( (Bid_ID__r.recordTypeId=:CostComponentUtilCls.recordMapId.get('Bid__c-Bid Form') and Bid_ID__r.Bid_Round_Status__c=:OmnicomConstant.BID_ROUND_STATUS_SETTING_UP) or 
     (Bid_ID__r.recordTypeId=:CostComponentUtilCls.recordMapId.get('Bid__c-Supplier Bid Request') and Bid_ID__r.Supplier_Bid_Request_Status__c=:OmnicomConstant.SUPPLIER_BID_REQUEST_STATUS_DRAFTING and Bid_ID__r.Parent_Bid_Round__r.Bid_Round_Status__c=:OmnicomConstant.BID_ROUND_STATUS_SETTING_UP) )];
   for(Bid_Asset__c bidAsset:bidAssetList){     
     if(assetMap!=NULL&&assetMap.get(bidAsset.Asset_ID__c)!=NULL){
            OPS_Asset__c asset=new OPS_Asset__c();
            asset=assetMap.get(bidAsset.Asset_ID__c);
            bidAsset.AD_ID__c = asset.Ad_ID__c;
            bidAsset.Asset_Name__c = asset.Name;
            bidAsset.Asset_Type__c = asset.Asset_Type__c;
            bidAsset.Length__c = asset.Size__c;
            bidAsset.Asset_ID__c = asset.Id;
            bidAsset.Alternate_Asset_Deliverable_Identifier__c=asset.Alternate_Asset_Deliverable_Identifier__c;
            bidAsset.Quantity__c=asset.Quantity__c;
            bidAsset.Asset_Derivative_Type__c=asset.Asset_Derivative_Type__c;
            updatedBidAssetList.add(bidAsset);
 
     }                           
   }
   if(updatedBidAssetList!=NULL&&updatedBidAssetList.size()>0){
      update updatedBidAssetList;
   }
   
 /*******************************************************************
    Purpose     :  This code is used to update the Total no.of assets on deliverable object whenever asset status is getting updated
    Adportal-1195
    Developer: Prapoorna.....12/12/2016
  *******************************************************************
    Set<id> devrIds = new Set<id>();
    for(OPS_Asset__c OPSAsst : assetMap.Values()){
         devrIds.add(OPSAsst.Deliverable__c);
    }
    System.debug('............devrIds ...........'+devrIds);

    Map<id, Job_Asset__c> JobAssetMap = new Map<id, Job_Asset__c>([SELECT id, Total_No_Of_Assets__c FROM Job_Asset__c WHERE id IN: devrIds]);   
    String jobId = '';
    String NoOfAssets;
    
    for(AggregateResult arrRes : [SELECT Deliverable__c der, Status__c st, SUM(Quantity__c) qn FROM OPS_Asset__c WHERE Deliverable__c IN: devrIds GROUP BY Status__c, Deliverable__c ORDER BY Deliverable__c]){    
        if(!jobId.equals((Id)arrRes.get('der'))){
           jobId = (Id)arrRes.get('der');
           NoOfAssets = '';
        //Decimal Qnty = (Decimal)arrRes.get('qn');
        }
        if(arrRes.get('st').equals('Under Development'))
          NoOfAssets  += (NoOfAssets != '') ? '; Under Development -'+ Integer.valueOf(arrRes.get('qn')) : 'Under Development -'+ Integer.valueOf(arrRes.get('qn'));
           //NoOfAssets  += (NoOfAssets != '') ? '; Under Development -'+ Qnty.round(System.RoundingMode.DOWN) : 'Under Development -'+ arrRes.get('qn');
        else if(arrRes.get('st').equals('Finished'))
           NoOfAssets  += (NoOfAssets != '') ? '; Finished -'+ Integer.valueOf(arrRes.get('qn')) : 'Finished -'+ Integer.valueOf(arrRes.get('qn'));
        else if(arrRes.get('st').equals('Cancelled'))
           NoOfAssets  += (NoOfAssets != '') ? '; Cancelled -'+ Integer.valueOf(arrRes.get('qn')) : 'Cancelled -'+ Integer.valueOf(arrRes.get('qn'));    
           //NoOfAssets = NoOfAssets.round(System.RoundingMode.DOWN);    
        
        JobAssetMap.get(jobId).Total_No_Of_Assets__c = NoOfAssets;
        System.debug('...........NoOfAssets.........'+NoOfAssets);
    }
    System.debug('............JobAssetMap.values()...........'+JobAssetMap.values());
    Update JobAssetMap.values();  
 ******/
 }
 
}
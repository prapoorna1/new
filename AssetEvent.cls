/*************************************************************************************** 
Name:  AssetEvent class 
Copyright © 2015  Omnicom Group Inc.
================================================================= 
================================================================= 
This class is used contain asset related trigger event funcationality 
=================================================================
================================================================= 
History  
-------
VERSION  AUTHOR              DATE         DETAIL                

1.0 -    Soundararaja A      8/2/2015    
*****************************************************************************************/
public class AssetEvent{

 /*******************************************************************
    Purpose     :  This method will be executed when Asset records are updated and used to update the Bid Asset associated to asset
    Parameters  : componentList-trigger.new and 
    Returns     : void
    ********************************************************************/
 public static void InitiatingEventsAFterUpdate(map<Id,OPS_Asset__c > assetMap,map<Id,OPS_Asset__c > oldAssetMap){
   AssetUtil.updateBidAssetDetails(assetMap);
 }

}
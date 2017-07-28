/*************************************************************************************** 
Name:  BidLineItemEvent class 
Copyright � 2015  Omnicom Group 
================================================================= 
================================================================= 
This class will be used to handle different trigger Events and will call appropriate methods based on the BidLineItem data
available in the Event
========================================================================================
========================================================================================
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    Soundararaja A      8/17/2015     
*****************************************************************************************/
public  with sharing class BidLineItemEvent {
 /*******************************************************************
    Purpose     :  This method will be executed during before BidLineItem insert
    Parameters  : componentList-trigger.new of BidLineItem 
    Returns     : void
    ********************************************************************/
public static void InitiatingEventsBeforeInsert(List<Bid_Line_Item__c > bidLineItemList){
  BidLineItemUtilCls.updateLineItem(bidLineItemList);
}
 /*******************************************************************
    Purpose     :  This method will be executed during before BidLineItem update
    Parameters  : componentList-trigger.new of BidLineItem 
    Returns     : void
    ********************************************************************/
public static void InitiatingEventsBeforeUpdate(List<Bid_Line_Item__c > bidLineItemList,Map<Id,Bid_Line_Item__c> oldBidlineItemMap){
   BidLineItemUtilCls.updateLineItem(bidLineItemList);

}
}
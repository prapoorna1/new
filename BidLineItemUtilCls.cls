/******************************************************************************** 
Name:  CostComponentUtilCls class 
Copyright © 2014  OmnicCom Group
================================================================= 
================================================================= 
A util class to update BidLineItem
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    A Soundararaja      31/7/2014     INITIAL DEVELOPMENT
*********************************************************************************/
public Class BidLineItemUtilCls{
    //Method developed for ADPORTAL-612 : Developer: Vijay Ramesh
 public static void updateLineItem(list<Bid_Line_Item__c> bidLineItemList){
    for(Bid_Line_Item__c bidLineItem:bidLineItemList){
        bidLineItem.Rich_Text_Value_Cognos__c = bidLineItem.Rich_Text_Value__c;    //Needed due to a Salesforce limitation on converting rich text fields to a text string    
        if(bidLineItem.Rich_Text_Value_Cognos__c != NULL){
            bidLineItem.Rich_Text_Value_Cognos__c = ConvertRichToCognosCls.updateCognosText(bidLineItem.Rich_Text_Value_Cognos__c);
        }
    }
 }    
    
  public static void updateLineItemTotal(LIST<Bid_Line_Item__c> bidLineItemList){   
 }  
 
 public static void updateBidLineItemTotal(List<Bid_Line_Item__c> bidLineItemList){
   Set<Id>  bidSectionIdlst=new Set<Id>();
   Set<Id>  bidSummaryIdlst=new Set<Id>();
   Set<Id>  bidSubTotalIdlst=new Set<Id>(); 
   List<Bid_Line_Item__c> updatedItemList=new List<Bid_Line_Item__c>();
   system.debug('#bidLineItemList'+bidLineItemList);
   for(Bid_Line_Item__c bidLineItem:bidLineItemList){
      if(bidLineItem.Type__c=='Line Item'){
        if(bidLineItem.Section__c!=NULL){
            bidSectionIdlst.add(bidLineItem.Section__c);
        }
        if(bidLineItem.Summary__c!=NULL){
            bidSummaryIdlst.add(bidLineItem.Summary__c);
        }  
      }
      if(bidLineItem.Type__c=='Summary'){
        if(bidLineItem.SubTotal__c!=NULL){
            bidSubTotalIdlst.add(bidLineItem.SubTotal__c);
        
        }
      }
   }
   if(bidSubTotalIdlst!=NULL&&bidSubTotalIdlst.size()>0){
       If(OMCTriggerHelper.ExecutedTriggers.contains('updateBidLineItemTotal'))
       return;
       OMCTriggerHelper.ExecutedTriggers.add('updateBidLineItemTotal');
   }
     for (AggregateResult ar : [select SubTotal__c subtotalId, sum(Total__c) total from Bid_Line_Item__c where  SubTotal__c=:bidSubTotalIdlst and Type__c='Summary' group by SubTotal__c])
  {
                updatedItemList.add(new Bid_Line_Item__c(Id = (Id) ar.get('subtotalId'),Total__c = (Decimal) ar.get('total')));
  }
      update updatedItemList; 
}
  
  public static void validateBidLineItem(LIST<Bid_Line_Item__c> bidLineItemList){   
  }
  // Is_Required__c feid is true and checking is there value in Item,name is required
  public static void requiredItemAndNameValues(List<Bid_Line_Item__c>  bidformItemList){
  Id bidFormLineItemRecordId;
  List <recordtype> bidformItemFormRecId = [select id from recordtype where name = 'Bid Form Item' and SobjectType = 'Bid_Line_Item__c'];       
      for (recordtype recordType: bidformItemFormRecId ) {
              bidFormLineItemRecordId = recordType.Id;
      }
          
      for(Bid_Line_Item__c bidFrmlst : bidformItemList ){
          if(bidFrmlst.RecordTypeId == bidFormLineItemRecordId )
          if(bidFrmlst .Is_Required__c ==true ){
              if(bidFrmlst.Item_Code__c == null)// && bidFrmlst.Item_Code__c =='')
              {
              bidFrmlst.Item_Code__c.addError('Required field value');
              }
              if(bidFrmlst.Name__c ==null)// && bidFrmlst.Name__c == '')
              {
              bidFrmlst.Name__c.addError('Required field value');            
              }
          }
      }  
  }  
  public static void deleteSectionBidLineItem(List<Bid_Line_Item__c>  bidLineItemList){
        set<Id> sectionSet=new set<Id>();
        for(Bid_Line_Item__c bidLineItem: bidLineItemList){
            if(bidLineItem.Type__c=='Section'){
                sectionSet.add(bidLineItem.Id);
            }
        } 
      if(sectionSet!=null&&sectionSet.size()>0){
          if(OMCTriggerHelper.ExecutedTriggers.contains('deleteSectionBidLineItem'))
          return;
          OMCTriggerHelper.ExecutedTriggers.add('deleteSectionBidLineItem');
          deleteLineItem(sectionSet);
      }
   }
   @future
   public static void deleteLineItem(set<Id> sectionSet){ 
          List<Bid_Line_Item__c> lineItemList=[Select id from Bid_Line_Item__c where section__c=:sectionSet ];
          if(lineItemList!=null&&lineItemList.size()>0){
            delete lineItemList;
          }
     }
   
}
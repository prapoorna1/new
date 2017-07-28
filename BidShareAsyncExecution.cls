/******************************************************************************** 
Name:  BidShareAsyncExecution 
Copyright © 2015  Omnicom Group 
================================================================= 
================================================================= 
This class have logic to add bids to Portal Users
=================================================================
================================================================= 
History  
-------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    SOUNDARARAJA A      5/04/2014    INITIAL DEVELOPMENT 
*********************************************************************************/
public class BidShareAsyncExecution implements Queueable {
   
     public  map<Id,Id>  portalContactUserMap { get; set; }
     public  map<String,set<Id>>  bidFormContactMap { get; set; }
     public Boolean isPortalUserCreation { get; set; }
     public list < Bid_Supplier_Contact__c > primaryBidSupplierContactList { get; set; }
     public set<Id> supplierBidIdSet { get; set; }
     
     //Constructor to populate the bidFormContactMap and portalContactUserMap based on logic on bidSupplierContactSet
     public BidShareAsyncExecution(set<Id> bidSupplierContactSet,map<Id,Id> portalContactUserMapParams){
                    supplierBidIdSet=new set<Id>(); 
                    primaryBidSupplierContactList = [Select Id,Bid_ID__c,Contact_ID__c,Bid_ID__r.Parent_Bid_Account__c from Bid_Supplier_Contact__c where Id = :bidSupplierContactSet ];
                   
                    System.debug('xxxxxx'+ primaryBidSupplierContactList );
                    bidFormContactMap=new map<String,set<Id>>();
                    
                    for (Bid_Supplier_Contact__c bidSupplierContact: primaryBidSupplierContactList) {
                        
                                //create a map for inserting share record for old cloned bids for the newly added bidSupplierContact
                                set<Id> contactSet;
                                if(bidFormContactMap!=NULL&&bidFormContactMap.get(bidSupplierContact.Bid_ID__r.Parent_Bid_Account__c)==NULL){
                                    contactSet=new set<Id>();
                                    contactSet.add(bidSupplierContact.contact_ID__c);
                                    bidFormContactMap.put(bidSupplierContact.Bid_ID__r.Parent_Bid_Account__c,contactSet);
                                }
                                else {
                                    contactSet=bidFormContactMap.get(bidSupplierContact.Bid_ID__r.Parent_Bid_Account__c);
                                    contactSet.add(bidSupplierContact.contact_ID__c);
                                    bidFormContactMap.put(bidSupplierContact.Bid_ID__r.Parent_Bid_Account__c,contactSet);
                                } 
                                supplierBidIdSet.add(bidSupplierContact.Bid_ID__c);
                        
                    }
                    portalContactUserMap=portalContactUserMapParams;
                    
                    isPortalUserCreation=true;
     }
    
     //Method to update the bid Share records for primary and cloned supplier bids for the new contacts added
     public void execute(QueueableContext context) {
            try{
            
                     list<Bid_Supplier_Contact__c> bidSupplierContactList=new list<Bid_Supplier_Contact__c>();
                     
                     //Getting List of Cloned Supplier bids
                     list<Bid__c> bidList=[Select Id,Parent_Bid_Account__c,(Select Contact_ID__c from Bid_Supplier_Contacts__r) from Bid__c where  Parent_Bid_Account__c=:bidFormContactMap.keySet() and RecordType.Name in ('Supplier Bid Response' ) and Is_Supplier_Primary__c=false];
                     system.debug('#bidList '+bidList);
                     for(Bid__c bid:bidList){
                        if(bidFormContactMap!=NULL&&bidFormContactMap.get(bid.Parent_Bid_Account__c)!=NULL){
                           set<Id> contactSet=bidFormContactMap.get(bid.Parent_Bid_Account__c);
                           set<Id> exisitingContactSet = new set<Id>();
                           
                           for(Bid_Supplier_Contact__c bsc:bid.Bid_Supplier_Contacts__r){
                           	 exisitingContactSet.add(bsc.Contact_ID__c);
                           }
                           
                           for(Id contactId:contactSet){
                           	    if(!exisitingContactSet.contains(contactId)){
	                                Bid_Supplier_Contact__c bidSupplierContact=new Bid_Supplier_Contact__c();
	                                bidSupplierContact.Bid_ID__c=bid.Id;
	                                bidSupplierContact.Contact_ID__c=contactId;
	                                bidSupplierContactList.add(bidSupplierContact);
                           	    }
                            }
                            
                        }
                         supplierBidIdSet.add(bid.Id);
                     }
                     //Adding Bid Supplier Contact to Cloned supplier bids for the new supplier user added
                     if(bidSupplierContactList!=NULL&&bidSupplierContactList.size()>0){
                        insert bidSupplierContactList;
                     }
                     //bid supplier contacts for the primary supplier bids are added here
                     if(primaryBidSupplierContactList!=NULL&&primaryBidSupplierContactList.size()>0){
                        bidSupplierContactList.addAll(primaryBidSupplierContactList);
                     }
                     list<Bid__Share> bidShareList=new list<Bid__Share>();
                     map<Id,String> supplierAccessLevelMap=getSupplierBidAccessStatus(supplierBidIdSet);
                     //share
                     for(Bid_Supplier_Contact__c  bisupplier: bidSupplierContactList){
                             if(portalContactUserMap!=NULL&&portalContactUserMap.get(bisupplier.contact_ID__c)!=NULL && supplierAccessLevelMap!=NULL && supplierAccessLevelMap.get(bisupplier.Bid_ID__c) != NULL){
                                
                                 Bid__Share bidShare= (Bid__Share)ApexSharing.generateShare('Bid__c',bisupplier.Bid_ID__c,portalContactUserMap.get(bisupplier.contact_ID__c),supplierAccessLevelMap.get(bisupplier.Bid_ID__c));
                                 bidShareList.add(bidShare);
                                 
                             }
                     }
                     //Inserting bid share records for the primary supplier bids as well as cloned supplier bids
                     if(bidShareList!=NULL&&bidShareList.size()>0){
                        Database.insert( bidShareList);
                     } 
                    
             }catch(Exception ex){
                System.debug('Portal Users Bid Share Failed :: '+ ex.getStackTraceString());
             }  
         }
    
     
         public static map<id,String> getSupplierBidAccessStatus(set<Id> supplierBidIdSet){
        
            list<Bid__c> supplerBidList=[SELECT Id, Supplier_Bid_Response_Status__c, Is_Invitation_Sent__c, Parent_Bid_Round__r.Bid_Round_Status__c FROM Bid__c where Id =: supplierBidIdSet];
            map<Id,String> supplierAccessLevelMap=new map<Id,String>();
            
            for(Bid__c supplierBid : supplerBidList)
            {
                if(supplierBid.Supplier_Bid_Response_Status__c == 'Submitted'||supplierBid.Parent_Bid_Round__r.Bid_Round_Status__c=='Closed For Submission')
                {
                    supplierAccessLevelMap.put(supplierBid.Id,OmnicomConstant.READ_ACCESS_LEVEL);
                }
                else if(supplierBid.Parent_Bid_Round__r.Bid_Round_Status__c == 'Open For Submission' )
                {
                    supplierAccessLevelMap.put(supplierBid.Id,OmnicomConstant.WRITE_ACCESS_LEVEL);
                }
                
            }
            return supplierAccessLevelMap;
       }
}
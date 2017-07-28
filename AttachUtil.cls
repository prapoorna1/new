/******************************************************************************** 
Name:  AttachUtil
Copyright © 2016  Omnicom Group Inc.
================================================================= 
================================================================= 
AttachUtil
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR				DATE		DETAIL                
1.0     <unkown>      		<unknown>	INITIAL DEVELOPMENT
1.0.4.1	Daryl Reisfeld		2016-01-29	Added custom permission exception to bid attachment delete validation method (validateAttachmentDelete)

*********************************************************************************/ 

public with sharing class AttachUtil {

	//API Name of the custom permission that permits deleted attachments from submitted bids
    public static final String CUSTOM_PERM_DELETE_SUB_BID_ATTACH = 'Delete_Submitted_Bid_Attachments'; //R 1.0.4.1: Added
    
    //Error message string constants
    public static final String ERR_MSG_BID_RESPONSE_ATTACH_DELETE = Label.Error_Submitted_Bid_Response_Attachment_Delete; //R 1.0.4.1: Added
	
	
/*****************************************************************************************************************************************
    Purpose     :  This method is used to change Attachment Internal to True For Job_Jacket__c, Internal to False For Bid__c 
    Parameters  :  componentList -List<Attachment>, Before
    Returns     :  void
******************************************************************************************************************************************/
    public static void changeInternal(List<Attachment> lisAttachs)
    {
        Savepoint sp = Database.setSavepoint();
        try {
            for(Attachment record:lisAttachs)  
                 {
                     String bject = KeyPrefix.GetKeyPrefix(record.ParentId);
                     if(bject == 'Job_Jacket__c')
                     {
                        record.IsPrivate = TRUE;
                     }
                     else if(bject == 'Bid__c')
                     {
                        record.IsPrivate = FALSE;
                     }
                 }
            } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('Exception ex:' + ex);
        }
    }
    
/*****************************************************************************************************************************************
    Purpose     :  This method is used to add components(attachments,etc) to new supplier bid at the time of attaching after supplier add. 
    Parameters  :  componentList -List<Attachment>, After
    Returns     :  void
******************************************************************************************************************************************/
    public static void AttachBid(List<Attachment> lisAttachs)
    {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<Id> bidFrm = new Set<Id>();
            Set<Id> JobJacket = new Set<Id>();
            if(lisAttachs != null && lisAttachs.size() > 0)
            {
                for(Attachment la : lisAttachs)
                {
                    if(la.ParentId != null & la.IsPrivate == False)
                    {
                        String bject = KeyPrefix.GetKeyPrefix(la.ParentId);
                        if(bject == 'Bid__c')
                        {
                         bidFrm.add(la.ParentId);
                        }
                    }
                }
            }
            List<Bid__c> listBid = New List<Bid__c>();
            listBid = [SELECT Id, Parent_Bid_Round__c FROM Bid__c WHERE Parent_Bid_Round__c IN: bidFrm];
            list<Attachment> bidAttachmentL=new list<Attachment>();            
            if(listBid != null && listBid.size() > 0)
            {
                for(Attachment lisAttach : lisAttachs)
                {
                    for(Bid__c lisBi : listBid)
                    {
                        Attachment supplierAttachment;
                        if(lisAttach.ParentId == lisBi.Parent_Bid_Round__c && lisAttach.IsPrivate != True)
                        {
                            supplierAttachment=lisAttach.clone();
                            supplierAttachment.ParentId=lisBi.Id;
                            bidAttachmentL.add(supplierAttachment);
                        }
                    }
                }
            }
            if(bidAttachmentL!=null&&bidAttachmentL.size()>0){
                        insert bidAttachmentL; 
                    }
            } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('Exception ex:' + ex);
        }
    }
    
/*****************************************************************************************************************************************
    Purpose     :  This method is used to add components(attachments,etc) to new supplier bid at the time of attaching after supplier add. 
    Parameters  :  componentList -List<Attachment>, After
    Returns     :  void
******************************************************************************************************************************************/
    public static void AttachJob(List<Attachment> lisAttachs, map<Id,set<Id>> jobBidMap, set<Id> bidFormId)
    {
        Savepoint sp = Database.setSavepoint();
        try {            
            Set<Id> BidFrm = new Set<Id>();
            List<Bid__c> liBid = new List<Bid__c>();
            list<Attachment> bidAttachmentL=new list<Attachment>();
            liBid = [SELECT Id, Job_Jacket_Name__c , Parent_Bid_Process_Id__c From Bid__c Where Job_Jacket_Name__c IN : jobBidMap.KeySet() AND Id IN : bidFormId];
            for(Bid__c obj : liBid)
            {  
                for(Attachment attach : lisAttachs)
                {
                   if(attach.ParentId == obj.Job_Jacket_Name__c)
                   {
                       Attachment supplierAttachment;
                            if(attach.IsPrivate != True)
                            {
                                supplierAttachment=attach.clone();
                                supplierAttachment.ParentId=obj.Id;
                                bidAttachmentL.add(supplierAttachment);
                            }
                   }
                }
            }  
            if(bidAttachmentL!=null&&bidAttachmentL.size()>0){
                        insert bidAttachmentL; 
                    }
            } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('Exception ex:' + ex);
        }
    }
/*****************************************************************************************************************************************
    Purpose     :  Validates if attachment delete action is permissible
    Parameters  :  map of Bid__c Ids with list of attachments to be deleted
    Returns     :  void
******************************************************************************************************************************************/
    public static void validateAttachmentDelete(map<Id,list<Attachment>> attachmentMap)
    {
    	    	
        Savepoint sp = Database.setSavepoint();
        
        try {               
                List<Bid__c> supplierBidList = new List<Bid__c>();
                supplierBidList = [Select Id, Supplier_Bid_Response_Status__c From Bid__c Where Id IN : attachmentMap.keySet() AND Supplier_Bid_Response_Status__c = 'Submitted'];
                
                if((supplierBidList != NULL) && (supplierBidList.size() > 0)) { //R 1.0.4.1: Added so CustomPermissionReader check is only called if there are records returned in supplierBidList
 
 					//Determine if the user context executing the action has the custom permission that allows them to override bid attachment deletion validation rule
    				CustomPermissionsReader cpr = new CustomPermissionsReader(); //R 1.0.4.1: Added user override condition
					Boolean userHasSubBidAttachOverridePermission = cpr.hasPermission(CUSTOM_PERM_DELETE_SUB_BID_ATTACH); //R 1.0.4.1: Added user override condition
                 
                	for(Bid__c supplierBid:supplierBidList){
                    	list<Attachment> attachmentList = attachmentMap.get(supplierBid.Id);
                    
                    	if((attachmentList != NULL) && (attachmentList.size() > 0) && (!userHasSubBidAttachOverridePermission)) { //R 1.0.4.1: Added user override condition
                        
                        	for(Attachment attachment:attachmentList ){
                            	attachment.addError(ERR_MSG_BID_RESPONSE_ATTACH_DELETE); //R 1.0.4.1: Changed to pull error message from custom label
                        	}
                    
                    	}
                	}
                }
           
           } catch (Exception ex) {
           		Database.rollback(sp);
            	System.debug('Exception ex:' + ex);
        }
        
    }

/*****************************************************************************************************************************************
    Purpose     :  <TO DO: Complete this documentation comment>
    Parameters  :  
    Returns     : 
******************************************************************************************************************************************/

    public static void  getAttachmentObjectMap(Map<Id,set<Id>> ObjectMap){
        system.debug('###### getAttachmentObjectMap(Map<Id,set<Id>> ObjectMap) Method');
        system.debug('###### ObjectMap'+ ObjectMap);
        map<Id,set<Id>> attachmentMap=new map<Id,set<Id>>();
        for(Attachment a:[Select Id,ParentId from Attachment where ParentId=:ObjectMap.keySet()]){
                if(ObjectMap!=NULL&&ObjectMap.get(a.ParentId)!=NULL){
                        set<Id> objectIdSet=new set<Id>();
                        objectIdSet.addAll(ObjectMap.get(a.ParentId));
                        if(objectIdSet!=NULL&objectIdSet.size()>0){
                            system.debug('#objectIdSet '+objectIdSet);
                            system.debug('#attachmentMap '+attachmentMap);
                            attachmentMap.put(a.Id,objectIdSet);
                        }
                }
        }
        system.debug('#attachmentMap '+attachmentMap);
        system.debug('#attachmentMap '+attachmentMap.get('00PK00000030yUIMAY'));
        if(attachmentMap!=NULL&&attachmentMap.size()>0){
                System.enqueueJob(new AttachmentAsyncExecution (attachmentMap,OmnicomConstant.INTIAL_DEPTH));
        }
    }
    
/*****************************************************************************************************************************************
    Purpose     :  <TO DO: Complete this documentation comment>
    Parameters  :  
    Returns     : 
******************************************************************************************************************************************/

     public static void  getAttachmentObjectMap(Map<Id,Id> ObjectMap){
        system.debug('###### getAttachmentObjectMap(Map<Id,Id> ObjectMap) Method');
        system.debug('###### ObjectMap'+ ObjectMap);
        map<Id,set<Id>> attachmentMap=new map<Id,set<Id>>();
        for(Attachment a:[Select Id,ParentId from Attachment where ParentId=:ObjectMap.keySet()]){
                if(ObjectMap!=NULL&&ObjectMap.get(a.ParentId)!=NULL){
                        Id objectId=ObjectMap.get(a.ParentId);
                        if(objectId!=NULL){
                            set<Id> ObjectSet=new set<Id>();
                            ObjectSet.add(objectId);
                            attachmentMap.put(a.Id,ObjectSet);
                        }
                }
        }
        if(attachmentMap!=NULL&&attachmentMap.size()>0){
                System.enqueueJob(new AttachmentAsyncExecution (attachmentMap,OmnicomConstant.INTIAL_DEPTH));
        }
    }
}
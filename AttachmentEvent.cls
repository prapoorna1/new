public class AttachmentEvent {
	
	public static void InitiatingEventsBeforeDelete(List<Attachment> lisAttachs){
    	Set<Id> ParentIds = new Set<Id>();  
        map<Id,list<Attachment>> attachmentMap=new map<Id,list<Attachment>>();
    	if(lisAttachs != NULL && lisAttachs.size() > 0){
            for(Attachment singleAttach : lisAttachs)
            {
                if(singleAttach.ParentId != null){
                	
                    String bject = KeyPrefix.GetKeyPrefix(singleAttach.ParentId);
                    if(bject == 'Bid__c'){
                    	
                    	ParentIds.add(singleAttach.ParentId);
                    	list<Attachment> attachmentList;
                    	if(attachmentMap!=NULL&&attachmentMap.get(singleAttach.ParentId)==NULL){
                    		attachmentList=new list<Attachment>();
                    		attachmentList.add(singleAttach);
                    		attachmentMap.put(singleAttach.ParentId,attachmentList);
                    	}
                    	else {
                    		attachmentList=attachmentMap.get(singleAttach.ParentId);
                    		attachmentList.add(singleAttach);
                    		attachmentMap.put(singleAttach.ParentId,attachmentList);
                    	}
                    }
                }
            }
        }
        if(attachmentMap!=NULL&&attachmentMap.size()>0){
        	 AttachUtil.validateAttachmentDelete(attachmentMap);
        }
       
    }
   
}
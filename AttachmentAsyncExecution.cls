/*********************************************************************************
Name:  BidShareAsyncExecution 
Copyright © 2015  Omnicom Group 
================================================================= 
================================================================= 
This class have logic to manage attachment copying 
=================================================================
================================================================= 
History  
------- 
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    SOUNDARARAJA A      11/25/2014    INITIAL DEVELOPMENT  
*********************************************************************************/
public class AttachmentAsyncExecution implements Queueable {  
    public  Map<Id,set<Id>>    attachmentObjectMap{ get; set; }
    public Integer depthLimit { get; set; }
    public AttachmentAsyncExecution (Map<Id,set<Id>> AttObjectMap,Integer level){
         attachmentObjectMap=AttObjectMap; 
         depthLimit=level; 
    }  
   public void execute(QueueableContext context) {
            Savepoint sp = Database.setSavepoint();
            Integer tempSize=0;
            Boolean isBreak=false;
            system.debug('#AttObjectMap '+attachmentObjectMap);
        try{
                for(Attachment a:[Select Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,IsPrivate,Id,IsDeleted,Name,ParentId from Attachment where IsPrivate != True AND Id=:attachmentObjectMap.KeySet()]){
                            system.debug('#Attachment '+a);
                             if(attachmentObjectMap!=NULL&&attachmentObjectMap.size()>0&&attachmentObjectMap.get(a.Id)!=NULL){
                                    if(a.BodyLength>OmnicomConstant.HEAP_SIZE_LIMIT){
                                        depthLimit=OmnicomConstant.DEPTH_LIMIT;
                                    } 
                                    set<Id> objectSet=attachmentObjectMap.get(a.Id); 
                            
                                    if(objectSet!=NULL&&objectSet.size()>0){ 
                                             for(Id objectId:objectSet){
                                                  tempSize=tempSize+a.BodyLength;
                                                  system.debug('#tempSize '+tempSize);
                                                  if(tempSize<OmnicomConstant.HEAP_SIZE_LIMIT&&(Limits.getLimitDMLStatements()-Limits.getDMLStatements())>3){
                                                        
                                                        Attachment attachment=a.clone();
                                                        attachment.ParentId=objectId;
                                                        insert attachment;
                                                        objectSet.remove(objectId);
                                                       
                                                     
                                                  }
                                                  else {
                                                    attachmentObjectMap.put(a.Id,objectSet);
                                                    isBreak=true;
                                                    break;
                                                  }
                                             }
                                             if(objectSet==NULL||objectSet.size()==0||objectSet.isEmpty()){
                                                attachmentObjectMap.remove(a.Id);
                                             }
                                    }
                          }
                          if(isBreak==true){
                            break;
                          }
                }
                if(depthLimit<OmnicomConstant.DEPTH_LIMIT&&attachmentObjectMap!=NULL&&attachmentObjectMap.size()>0){
                    
                    System.enqueueJob(new AttachmentAsyncExecution (attachmentObjectMap,++depthLimit));
                }
            
           }catch(Exception ex){
             Database.rollback(sp);
            System.debug('Copying attachment Failed :: '+ ex.getStackTraceString());
         }          
    }


}
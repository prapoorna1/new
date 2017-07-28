/*************************************************************************************** 
Name:  AutoCreateJobAsyncExecution class 
Copyright � 2016  Omnicom Group 
================================================================= 
================================================================= 

========================================================================================
========================================================================================
History  
-------
VERSION  AUTHOR              DATE         DETAIL                


*****************************************************************************************/

public with sharing class AutoCreateJobAsyncExecution implements Queueable{

    public Id JobId {get; set;}
    public Id UserId {get; set;}
    public String AccessType  {get; set;}
    public Boolean ReceiveNotificationFlagParam{get; set;}
    public Boolean ProuctionLeadFlagParam{get; set;}
    public Boolean BusineesAffairLeadFlagParam{get; set;}
    
    //Constructor to populate the paramenter values to be passed to createSupplierBidAndBidContacts method 
    public AutoCreateJobAsyncExecution (Id JobIdTemp,Id UserIdTemp,String AccessTypeTemp, Boolean receiveNotificationFlagParamTemp, Boolean ProuctionLeadFlagParamTemp, Boolean BusineesAffairLeadFlagParamTemp){
       
        JobId= JobIdTemp ;
        UserId= UserIdTemp ;
        AccessType= AccessTypeTemp ;
        receiveNotificationFlagParam= receiveNotificationFlagParamTemp;
        ProuctionLeadFlagParam= ProuctionLeadFlagParamTemp;
        BusineesAffairLeadFlagParam= BusineesAffairLeadFlagParamTemp;
        
     }
    
    public void execute(QueueableContext context) {
            system.debug('#####################AutoCreateSupplierBidAsyncExecution');
        
        Savepoint sp = Database.setSavepoint();
        try{
                //Calling helper class method if JobId and UserId are not null
                if(JobId!= null && UserId!= null){
                      CostComponentHelper.CreateJobTeam(JobId,UserId,AccessType,receiveNotificationFlagParam,ProuctionLeadFlagParam,BusineesAffairLeadFlagParam);
                }
        }
        catch(Exception ex){
                Database.rollback(sp);
                System.debug('Failed to execute CreateJobTeam method :: '+ ex.getStackTraceString());
         } 
    }
}
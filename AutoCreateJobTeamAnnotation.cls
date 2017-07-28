public with sharing class AutoCreateJobTeamAnnotation {
    
    @InvocableMethod 
    public static void createJobTeam(List<SetParameters> paramsList){
        Savepoint sp = Database.setSavepoint();
        SetParameters params = new SetParameters();
        if (paramsList !=null && paramsList.size() > 0) {
            params = paramsList[0];
        }
        try {  
            system.debug('@@@@@@@@@@@@@@params'+params); 
            if(params.ExecuteAsynchronously){
               // System.enqueueJob(new AutoCreateJobAsyncExecution(params.JobParam, params.UserParam, params.AccessTypeParam,true,false,false);
            }
            else{
               // CostComponentHelper.createSupplierBidAndBidContacts(params.JobParam, params.UserParam, params.AccessTypeParam);
                CostComponentHelper.CreateJobTeam(params.JobParam, params.UserParam, params.AccessTypeParam,params.receiveNotificationFlagParam,false,false);
    
            }
        }
        catch(Exception ex){
            Database.rollback(sp);
            System.debug('Failed to execute :: '+ ex.getStackTraceString());
         } 
    }
    
    public class SetParameters{
        @InvocableVariable( required=true label='Execute Asynchronously?')
        public Boolean ExecuteAsynchronously ;
        
        @InvocableVariable( required=true label='Job ID')
        public Id JobParam ;
        
        @InvocableVariable( required=true label='User ID')
        public Id UserParam ;
        
        @InvocableVariable( required=true label='Job Access Type' )
        public String AccessTypeParam;
        
        @InvocableVariable( required=true label='Role' )
        public String RoleParam;
        
       @InvocableVariable( required=true label='Receive Bid Notifications' )
        public Boolean receiveNotificationFlagParam;
    } 
    
}
public with sharing class AutoCreateSupplierBidAnnotation {
    
    @InvocableMethod 
    public static void createSupplierBidAndBidContacts(List<SetParameters> paramsList){
        Savepoint sp = Database.setSavepoint();
        SetParameters params = new SetParameters();
        if (paramsList !=null && paramsList.size() > 0) {
            params = paramsList[0];
        }
        try {  
        	system.debug('@@@@@@@@@@@@@@params'+params); 
            if(params.ExecuteAsynchronously){
                System.enqueueJob(new AutoCreateSupplierBidAsyncExecution(params.BidRoundParam, params.SupplierParam, params.SupplierContactsParam, params.BusinessRuleAddedFlagParam, params.PreventSupplierRemovalFlagParam, params.PreventSupplierContactRemovalFlagParam));
            }
            else{
                CostComponentHelper.createSupplierBidAndBidContacts(params.BidRoundParam, params.SupplierParam, params.SupplierContactsParam, params.BusinessRuleAddedFlagParam, params.PreventSupplierRemovalFlagParam, params.PreventSupplierContactRemovalFlagParam);
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
        
        @InvocableVariable( required=true label='Bid Round Id')
        public Id BidRoundParam ;
        
        @InvocableVariable( required=true label='Supplier Id')
        public Id SupplierParam ;
        
        @InvocableVariable( label='Supplier Contacts')
        public List<Id> SupplierContactsParam ;
        
        @InvocableVariable( label='Business Rule Added Flag')
        public Boolean BusinessRuleAddedFlagParam ;
        
        @InvocableVariable( label='Prevent Supplier Removal Flag')
        public Boolean PreventSupplierRemovalFlagParam ;
        
        @InvocableVariable( label='Prevent Supplier Contact Removal Flag')
        public Boolean PreventSupplierContactRemovalFlagParam ;
    }
    
}
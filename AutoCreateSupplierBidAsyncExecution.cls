/*************************************************************************************** 
Name:  AutoCreateSupplierBidAsyncExecution class 
Copyright � 2016  Omnicom Group 
================================================================= 
================================================================= 
Async class that queues the method that adds a supplier and/or contact(s) to a bid round based on the set of parameters passed.
========================================================================================
========================================================================================
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    Sharon              22/08/2016    

*****************************************************************************************/

public with sharing class AutoCreateSupplierBidAsyncExecution implements Queueable{
	public Id BidRoundParam {get; set;}
	public Id SupplierParam {get; set;}
	public List<Id> SupplierContactsParam {get; set;}
	public Boolean BusinessRuleAddedFlagParam {get; set;}
	public Boolean PreventSupplierRemovalFlagParam {get; set;}
	public Boolean PreventSupplierContactRemovalFlagParam {get; set;}
	
	//Constructor to populate the paramenter values to be passed to createSupplierBidAndBidContacts method 
	public AutoCreateSupplierBidAsyncExecution (Id BidRoundParamTemp,Id SupplierParamTemp,List<Id> SupplierContactsParamTemp, Boolean BusinessRuleAddedFlagParamTemp, Boolean PreventSupplierRemovalFlagParamTemp, Boolean PreventSupplierContactRemovalFlagParamTemp){
		
		BidRoundParam = BidRoundParamTemp;
		SupplierParam = SupplierParamTemp;
		SupplierContactsParam = SupplierContactsParamTemp ;
		BusinessRuleAddedFlagParam = BusinessRuleAddedFlagParamTemp;
		PreventSupplierRemovalFlagParam = PreventSupplierRemovalFlagParamTemp;
		PreventSupplierContactRemovalFlagParam = PreventSupplierContactRemovalFlagParamTemp;
	}
	
    public void execute(QueueableContext context) {
    		system.debug('#####################AutoCreateSupplierBidAsyncExecution');
    	
        Savepoint sp = Database.setSavepoint();
        try{
        		//Calling helper class method if BidRoundParam and SupplierParam are not null
        		if(BidRoundParam != null && SupplierParam != null){
                	CostComponentHelper.createSupplierBidAndBidContacts(BidRoundParam, SupplierParam, SupplierContactsParam, BusinessRuleAddedFlagParam, PreventSupplierRemovalFlagParam, PreventSupplierContactRemovalFlagParam);
        		}
        }
        catch(Exception ex){
                Database.rollback(sp);
                System.debug('Failed to execute createSupplierBidAndBidContacts method :: '+ ex.getStackTraceString());
         } 
    }
}
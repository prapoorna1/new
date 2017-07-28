/******************************************************************************** 
Name:  IPFShare 
Copyright © 2014  Omnicom Group
================================================================= 
================================================================= 
This class is used to Implement functionality related to supplier account
=================================================================
=================================================================  
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    SOUNDARARAJA A      02/09/2015   INITIAL DEVELOPMENT
*/
public without sharing class AccountSupplierMetricsUtil {

/*******************************************************************
    Purpose     :  This method will be executed  to update Supplier Statictics
    Parameters  :  job Id list
    Returns     : void
    ********************************************************************/
  public static void updateJobSupplierMetrics(set<Id> jobIdList){
    
    if(jobIdList!=NULL&&jobIdList.size()>0){
        list<Account> supplierList=new list<Account>();
        map<Id,Account> accountMap=new map<Id,Account>();
        set<Id> accountIdSet=new set<Id>();
        List<Bid__c> bidList=[Select Parent_Account_Name__c from Bid__c where  Job_Jacket_Name__c=:jobIdList  and Job_Jacket_Name__c!=NULL and Parent_Account_Name__c!=NULL];
        for(Bid__c bid:bidList){
            accountIdSet.add(bid.Parent_Account_Name__c);
        }
         //Metric 5: YTD # of Jobs Bid On
        AggregateResult[] supplierAggregateResults=[Select Count_distinct(Job_Jacket_Name__c),Parent_Account_Name__c from Bid__c where  Job_Jacket_Name__c=:jobIdList  and Job_Jacket_Name__c!=NULL
                                                     and Supplier_Bid_Response_Status__c='Submitted' and RecordType.Name='Supplier Bid Response' and createdDate>LAST_N_QUARTERS:4 group by Parent_Account_Name__c];
        for(AggregateResult supplierAgg: supplierAggregateResults){
            Account supplier;
            if(accountMap!=NULL&&accountMap.get((Id)supplierAgg.get('Parent_Account_Name__c'))!=NULL){
                supplier= accountMap.get((Id)supplierAgg.get('Parent_Account_Name__c'));
            }
            else {
                supplier= new Account();
            }
            supplier.Id=(Id)supplierAgg.get('Parent_Account_Name__c');
            supplier.YTD_of_Jobs_Bid_On__c=(Decimal)supplierAgg.get('expr0');
            accountMap.put(supplier.Id,supplier);
            
        }
          Account accountRecord;
         if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdSet){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {accountRecord= new Account();}
                    accountRecord.Id=(id)accountId;
                    accountRecord.YTD_of_Jobs_Bid_On__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }
        //Metric 6: YTD # of Jobs Awarded Work
         supplierAggregateResults=[Select count_distinct(Job_Jacket_Name__c),Awarded_Supplier__c from Bid__c where Job_Jacket_Name__c=:jobIdList and Job_Jacket_Name__c!=NULL
                                                     and Cost_Component_Status__c='Awarding' and Awarded_Supplier__c!=null and (Job_Jacket_Name__r.Job_Jacket_Status__c='Open'
                                                      or Job_Jacket_Name__r.Job_Jacket_Status__c='Closed' )  and createdDate>LAST_N_QUARTERS:4 group by Awarded_Supplier__c];
        system.debug('#supplierAggregateResults'+supplierAggregateResults);
        for(AggregateResult supplierAgg: supplierAggregateResults){
            Account supplier;
            if(accountMap!=NULL&&accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'))!=NULL){
                supplier= accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'));
            }
            else {
                supplier= new Account();
            }
            supplier.Id=(Id)supplierAgg.get('Awarded_Supplier__c');
            supplier.YTD_of_Jobs_Awarded_Work__c=(Decimal)supplierAgg.get('expr0');
            accountMap.put(supplier.Id,supplier);
            
        }
         if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdSet){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {
                        accountRecord= new Account();
                    }
                    accountRecord.Id=(id)accountId;
                    accountRecord.YTD_of_Jobs_Awarded_Work__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }
        //Metric 7: # of Jobs in Production Currently
        List<String> bidStatus=new List<String>();
        bidStatus.add('Awarding');
        bidStatus.add('Delivering');
        bidStatus.add('Reconciling');
        bidStatus.add('Close');
        supplierAggregateResults=[Select count_distinct(Job_Jacket_Name__c),Awarded_Supplier__c from Bid__c where Job_Jacket_Name__c=:jobIdList and Job_Jacket_Name__c!=NULL and Awarded_Supplier__c!=NULL
                                                     and Cost_Component_Status__c=:bidStatus and
                                                      (Job_Jacket_Name__r.Job_Jacket_Stage__c='Production (4 of 7)' ) group by Awarded_Supplier__c];        
        for(AggregateResult supplierAgg: supplierAggregateResults){
            Account supplier;
            if(accountMap!=NULL&&accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'))!=NULL){
                supplier= accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'));
            }
            else {
                supplier= new Account();
            }
            supplier.Id=(Id)supplierAgg.get('Awarded_Supplier__c');
            supplier.Number_of_current_on_going_jobs__c=(Decimal)supplierAgg.get('expr0');
            accountMap.put(supplier.Id,supplier);
            
        }
         if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdSet){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {
                        accountRecord= new Account();
                    }
                    accountRecord.Id=(id)accountId;
                    accountRecord.Number_of_outstanding_bids__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }       
        if(accountMap!=NULL&accountMap.size()>0){
         update accountMap.Values();    
        }
    }
 }
}
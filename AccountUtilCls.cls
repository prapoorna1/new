/******************************************************************************** 
Name:  AccountUtilCls
Copyright © 2014  Omnicom Group
================================================================= 
================================================================= 
AccountUtilCls
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0-     A Soundararaja      12/16/14     INITIAL DEVELOPMENT
*********************************************************************************/ 
public without sharing class AccountUtilCls {  
    
  /*******************************************************************
    Purpose     :  This method will be executed  to update Supplier Statictics
    Parameters  :  account Id list
    Returns     : void
  ********************************************************************/
 @future
 public static void updateSupplierMetrics(set<Id> accountIdList){    
    list<Account> supplierList=new list<Account>();
    map<Id,Account> accountMap=new map<Id,Account>();
    //Parent_Account_Name__c  Awarded_Supplier__c
    if(accountIdList!=NULL&&accountIdList.size()>0&&!accountIdList.isEmpty()){
         //Metric 2: YTD OPS Awarded Work Value
        AggregateResult[] supplierAggregateResults=[Select sum(Total_Cost__c),Awarded_Supplier__c from Bid__c where Awarded_Supplier__c=: accountIdList and Awarded_Supplier__c!=NULL
                                                     and Cost_Component_Status__c='Awarding' and createdDate>LAST_N_QUARTERS:4 group by Awarded_Supplier__c  ];
        for(AggregateResult supplierAgg: supplierAggregateResults){
            Account supplier;
            if(accountMap!=NULL&&accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'))!=NULL){
                supplier= accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'));
            }
            else {
                supplier= new Account();
            }
            supplier.Id=(Id)supplierAgg.get('Awarded_Supplier__c');
            supplier.YTD_Spend__c=(Decimal)supplierAgg.get('expr0');
            accountMap.put(supplier.Id,supplier);
            
        }
        Account accountRecord;
        if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdList){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {
                        accountRecord= new Account();
                    }
                    accountRecord.Id=(id)accountId;
                    accountRecord.YTD_Spend__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }         
        //Metric 3: YTD # of Components Bid On        
         supplierAggregateResults=[Select Count_distinct(Supplier_Cost_Comp_Id__c),Parent_Account_Name__c from Bid__c where Parent_Account_Name__c=: accountIdList and Parent_Account_Name__c!=NULL
                                                     and Supplier_Bid_Response_Status__c='Submitted'  group by Parent_Account_Name__c];
        for(AggregateResult supplierAgg: supplierAggregateResults){
            Account supplier;
            if(accountMap!=NULL&&accountMap.get((Id)supplierAgg.get('Parent_Account_Name__c'))!=NULL){
                supplier= accountMap.get((Id)supplierAgg.get('Parent_Account_Name__c'));
            }
            else {
                supplier= new Account();
            }
            supplier.Id=(Id)supplierAgg.get('Parent_Account_Name__c');
            supplier.YTD_of_Bids_Submitted__c=(Decimal)supplierAgg.get('expr0');
            accountMap.put(supplier.Id,supplier);
        }
        if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdList){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {
                        accountRecord= new Account();
                    }
                    accountRecord.Id=(id)accountId;
                    accountRecord.YTD_of_Bids_Submitted__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }
        //Metric 4: YTD # of Components Awarded
        supplierAggregateResults=[Select count(Id),Awarded_Supplier__c from Bid__c where Awarded_Supplier__c=: accountIdList and Awarded_Supplier__c!=NULL
                                                     and Cost_Component_Status__c='Awarding' and createdDate>LAST_N_QUARTERS:4 group by Awarded_Supplier__c];     
        for(AggregateResult supplierAgg: supplierAggregateResults){
            Account supplier;
            if(accountMap!=NULL&&accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'))!=NULL){
                supplier= accountMap.get((Id)supplierAgg.get('Awarded_Supplier__c'));
            }
            else {
                supplier= new Account();
            }
            supplier.Id=(Id)supplierAgg.get('Awarded_Supplier__c');
            supplier.YTD_of_Bids_Awarded__c=(Decimal)supplierAgg.get('expr0');
            accountMap.put(supplier.Id,supplier);
        }
        if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdList){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {
                        accountRecord= new Account();
                    }
                    accountRecord.Id=(id)accountId;
                    accountRecord.YTD_of_Bids_Awarded__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }
        //Metric 5: YTD # of Jobs Bid On
        supplierAggregateResults=[Select Count_distinct(Job_Jacket_Name__c),Parent_Account_Name__c from Bid__c where Parent_Account_Name__c=: accountIdList and Parent_Account_Name__c!=NULL
                                                     and Supplier_Bid_Response_Status__c='Submitted' and createdDate>LAST_N_QUARTERS:4 group by Parent_Account_Name__c];
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
        if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdList){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {
                        accountRecord= new Account();
                    }
                    accountRecord.Id=(id)accountId;
                    accountRecord.YTD_of_Jobs_Bid_On__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }
        //Metric 6: YTD # of Jobs Awarded Work
        supplierAggregateResults=[Select count_distinct(Job_Jacket_Name__c),Awarded_Supplier__c from Bid__c where Awarded_Supplier__c=: accountIdList and Awarded_Supplier__c!=NULL
                                                     and Cost_Component_Status__c='Awarding' and (Job_Jacket_Name__r.Job_Jacket_Status__c='Open'
                                                      or Job_Jacket_Name__r.Job_Jacket_Status__c='Closed' ) and createdDate>LAST_N_QUARTERS:4 group by Awarded_Supplier__c];  
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
                for(id accountId:accountIdList){
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
        supplierAggregateResults=[Select count_distinct(Job_Jacket_Name__c),Awarded_Supplier__c from Bid__c where Awarded_Supplier__c=: accountIdList and Awarded_Supplier__c!=NULL
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
                for(id accountId:accountIdList){
                    if(accountMap!=NULL&&accountMap.get(accountId)!=NULL){
                       accountRecord= accountMap.get(accountId);
                    }
                    else {
                        accountRecord= new Account();
                    }
                    accountRecord.Id=(id)accountId;
                    accountRecord.Number_of_current_on_going_jobs__c=0;
                    accountMap.Put(accountRecord.Id,accountRecord);
                }
         }
        //Metric 8: # of Bids Outstanding
         supplierAggregateResults=[Select Count_distinct(Supplier_Cost_Comp_Id__c),Parent_Account_Name__c from Bid__c where Parent_Account_Name__c=: accountIdList and Parent_Account_Name__c!=NULL
                                                     and Supplier_Bid_Response_Status__c='Submitted'  and Parent_Bid_Round__r.Parent_Bid_Process_Id__r.Cost_Component_Status__c='Sourcing' group by Parent_Account_Name__c];
        for(AggregateResult supplierAgg: supplierAggregateResults){
            Account supplier;
            if(accountMap!=NULL&&accountMap.get((Id)supplierAgg.get('Parent_Account_Name__c'))!=NULL){
                supplier= accountMap.get((Id)supplierAgg.get('Parent_Account_Name__c'));
            }
            else {
                supplier= new Account();
            }
            supplier.Id=(Id)supplierAgg.get('Parent_Account_Name__c');
            supplier.Number_of_outstanding_bids__c=(Decimal)supplierAgg.get('expr0');
            accountMap.put(supplier.Id,supplier);
        }
        if(supplierAggregateResults.size()==0){  
                for(id accountId:accountIdList){
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
   /*******************************************************************
    Purpose     :  This method will be executed  to insert Account Share for Portal User
    Parameters  :  User List
    Returns     : void
  ********************************************************************/ 
    
 public static void insertAccountShare(Map<id, id> userContactMap){
        set<Id> contactIdSet= userContactMap.keySet();
        list<Contact> contactList=[Select Id,accountId from Contact where Id=:contactIdSet];
        map<Id,Id> accountUserMap =new map<Id,Id>();
        list<AccountShare> accShareList=new List<AccountShare>();
        for(Contact contact:contactList){
            if(userContactMap.get(contact.Id)!=NULL){
                AccountShare accShare=ApexSharing.manualShareAccount(contact.accountId,userContactMap.get(contact.Id));
                accShareList.add(accShare);
            }
        }
        if(accShareList!=NULL&&accShareList.size()>0){
            Database.insert( accShareList);
        }
  }
  
  
  public static void validateAccountUpdate(list<Account> accountList){
    for(Account account:accountList){
        account.addError('Please contact the OPS Support Desk to deactivate this supplier account');
    }
  }
}
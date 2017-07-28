/******************************************************************************** 
Name:  BlockDeleteHelper
Copyright © 2014  Omnicom Group
================================================================= 
================================================================= 
BlockDeleteHelper
=================================================================
================================================================= 
History  
-------
VERSION  AUTHOR              DATE         DETAIL                
1.0-     Vijay Ramesh       03/16/15     INITIAL DEVELOPMENT
*********************************************************************************/
public class BlockDeleteHelper
{
    public static void blockIPFRemove(List<Integrated_Project_Folder__c> listIPF)
    {
        try{
            if(listIPF != null && listIPF.size() > 0){
                System.debug('Record'+listIPF);
                // fetching the exception message from the custom setting
                    if(listIPF != null)
                    {
                    System.debug('Record'+listIPF);
                        for(Integrated_Project_Folder__c ipf : listIPF)
                        {
                        System.debug('Record'+ipf);
                            if((ipf.Status__c != 'Cancelled') && (ipf.Status__c != 'Widowed')) {                                                           
                                ipf.addError('Record Delete not possible');}
                        }
                }
            }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
    public static void blockJobdeliverableRemove(List<Job_Jacket_Deliverable__c> listJobdeliverables)
    {
        try{
                // fetching the exception message from the custom setting
                if(listJobdeliverables != null)
                {
                    for(Job_Jacket_Deliverable__c job : listJobdeliverables)
                    {
                        if(job.Status__c != 'Under Development')
                        {
                            // throwing exception of removal in UI
                            job.addError('Record Delete not possible');
                        }
                    }
                }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
    public static void blockJobRemove(List<Job_Jacket__c> listJob)
    {
        try{
                // fetching the exception message from the custom setting
                if(listJob != null)
                {
                    for(Job_Jacket__c jobOb : listJob)
                    {
                        if(jobOb.Job_Jacket_Status__c != 'Initiating')
                        {
                            // throwing exception of removal in UI
                            jobOb.addError('Record Delete not possible');
                        }
                    }
                }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
    public static void blockAssetRemove(List<OPS_Asset__c> listAsset)
    {
        try{
                // fetching the exception message from the custom setting
                if(listAsset != null)
                {
                    for(OPS_Asset__c AssetsObj : listAsset)
                    {
                        if(AssetsObj.Status__c != 'Under Development')
                        {
                            // throwing exception of removal in UI
                            AssetsObj.addError('Record Delete not possible');
                        }
                    }
                }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
    public static void blockFSAccountremove(List<FS_Account__c> listFSAccount, String ProfileName)
    {
        try{
                // fetching the exception message from the custom setting
                if(listFSAccount != null && ProfileName != null)
                {
                    for(FS_Account__c accobj : listFSAccount)
                    {
                        if(ProfileName != 'CIIntegration' && ProfileName != 'System Administrator')
                        {
                            // throwing exception of removal in UI
                            accobj.addError('Record Delete not possible');
                        }                        
                    }
                }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
    public static void blockContactremove(List<Contact> listContact, List<Account> listAccount, String ProfileName)
    {
        try{
                Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Account']);
                // fetching the exception message from the custom setting
                if(listContact != null && ProfileName != null)
                {
                    for(Contact cnobj : listContact)
                    {
                        for(Account accobj : listAccount)
                        {
                            ///if(accobj.Id == cnobj.AccountId)
                            //{
                                if(rt_map.get(accobj.recordTypeID).name.containsIgnoreCase('ClientRepEnt') && (ProfileName != 'CIIntegration' && ProfileName != 'System Administrator'))
                                {
                                    // throwing exception of removal in UI
                                    cnobj.addError('Record Delete not possible');
                                }
                                if(rt_map.get(accobj.recordTypeID).name.containsIgnoreCase('SupplierRepEnt') && (ProfileName != 'CIIntegration' && ProfileName != 'System Administrator'))
                                {                                    
                                    // throwing exception of removal in UI
                                    cnobj.addError('Record Delete not possible');
                                }
                            //}
                        }
                    }
                }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
    public static void blockCostComponentsremove(List<Bid__c> CostComponents)
    {
        try{
                Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Bid__c']);
                // fetching the exception message from the custom setting
                if(CostComponents != null)
                {
                    for(Bid__c bigbjg : CostComponents)
                    {
                        if(rt_map.get(bigbjg.recordTypeID).name.containsIgnoreCase('Cost Component') && bigbjg.Cost_Component_Status__c != 'Preparing')
                        {  
                             system.debug('#costcomponent'+bigbjg);
                            // throwing exception of removal in UI
                            bigbjg.addError('Record Delete not possible');
                        }
                        if(rt_map.get(bigbjg.recordTypeID).name.containsIgnoreCase('Supplier Bid Request') && bigbjg.Supplier_Bid_Request_Status__c != 'Producer Drafting' && bigbjg.Is_Supplier_Primary__c==true)
                        {
                            // throwing exception of removal in UI
                            bigbjg.addError('Record Delete not possible');
                        }
                        if(rt_map.get(bigbjg.recordTypeID).name.containsIgnoreCase('Bid Form') &&  ( (bigbjg.Bid_Round_Status__c != 'Open For Submission' && bigbjg.Entry_method__c == 'Internal user enters cost information')||(bigbjg.Bid_Round_Status__c != 'Setting Up'&& bigbjg.Entry_method__c == 'Supplier Enters Cost Information')))
                        {
                            // throwing exception of removal in UI
                            bigbjg.addError('Record Delete not possible');
                        }
                    }
                }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
    public static void blockAccountremove(List<Account> listAccount, String ProfileName)
    {
        try{
                Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Account']);
                // fetching the exception message from the custom setting
                if(listAccount != null && ProfileName != null)
                {
                    for(Account accobj : listAccount)
                    {
                        if(rt_map.get(accobj.recordTypeID).name.containsIgnoreCase('ClientRepEnt') && (ProfileName != 'CIIntegration' && ProfileName != 'System Administrator'))
                        {
                            // throwing exception of removal in UI
                            accobj.addError('Record Delete not possible');
                        }
                        if(rt_map.get(accobj.recordTypeID).name.containsIgnoreCase('SupplierRepEnt') && (ProfileName != 'CIIntegration' && ProfileName != 'System Administrator'))
                        {
                            // throwing exception of removal in UI
                            accobj.addError('Record Delete not possible');
                        }
                        if(rt_map.get(accobj.recordTypeID).name.containsIgnoreCase('OMCRepEnt') && (ProfileName != 'CIIntegration' && ProfileName != 'System Administrator'))
                        {
                            // throwing exception of removal in UI
                            accobj.addError('Record Delete not possible');
                        }
                        if(rt_map.get(accobj.recordTypeID).name.containsIgnoreCase('Brand') && (ProfileName != 'CIIntegration' && ProfileName != 'System Administrator'))
                        {
                            // throwing exception of removal in UI
                            accobj.addError('Record Delete not possible');
                        }
                    }
                }
            }Catch(Exception e)
            {System.debug('Exception'+e);}
    }
}
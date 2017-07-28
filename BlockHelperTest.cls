@isTest
public class BlockHelperTest {
    public static testMethod void testblockRemove()
    {        
    	Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);
        }
        List<Integrated_Project_Folder__c> listIPF = new List<Integrated_Project_Folder__c>();
        List<Job_Jacket__c> listJobbbbbb = new List<Job_Jacket__c>();
        List<FS_Account__c> listFAccount = new List<FS_Account__c>();
        UserRole userRoll = TestUtilities.getUserRole();         
        Profile userProfile = TestUtilities.getAdminProfile();
        User userRecord = TestUtilities.getTestUser(userProfile, userRoll);    
        RecordType recordtype = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' Limit 1];
        RecordType agencyRecord = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'OMCRepEnt'];        
        RecordType upplieraccount = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'SupplierRepEnt'];
        RecordType clientaccount = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'ClientRepEnt'];
        RecordType legalAccount = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Account' AND Name = 'Legal Entity'];
        
        Account parentAccount = new Account();
        parentAccount.Name = 'Test';
            System.RunAs(userRecord) {
                Insert parentAccount;
            }
        Account accountRecord = TestUtilities.getAccountDetails('TestAccount', parentAccount.Id, agencyRecord.Id, userRecord.Id);
             System.RunAs(userRecord) {
                Insert accountRecord;
            }
        Account upplieraccountRecord = TestUtilities.getAccountDetails('TestupplierAccount', parentAccount.Id, upplieraccount.Id, userRecord.Id);
             System.RunAs(userRecord) {
                Insert upplieraccountRecord;
            }
        List<Account> upplierlist = new List<Account>();
        upplierlist.add(upplieraccountRecord);
        Account clientaccountRecord = TestUtilities.getAccountDetails('TestclientAccount', parentAccount.Id, clientaccount.Id, userRecord.Id);
             System.RunAs(userRecord) {
                Insert clientaccountRecord;
            }
        List<Account> clienlist = new List<Account>();
        clienlist.add(upplieraccountRecord);
        Integrated_Project_Folder__c ipf = TestUtilities.getIPFDetails();
            System.RunAs(userRecord) {
                ipf.OwnerId = userRecord.id;
                ipf.Status__c = 'Open';
                Insert ipf;
            }       
                listIPF.add(ipf);
                
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,legalAccount.id,UserInfo.getUserId());
        System.RunAs(userRecord) {
        	insert accAgencyLegalEntity;
        }
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,legalAccount.id,UserInfo.getUserId());
        System.RunAs(userRecord) {
        	insert accClientLegalEntity; 
        }
        Job_Jacket__c jobbbbbb = TestUtilities.getJobDetail(ipf.id, accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
            System.RunAs(userRecord) {
                Insert jobbbbbb;
            }
                listJobbbbbb.add(jobbbbbb);
        BlockDeleteHelper.blockIPFRemove(listIPF);
        List<Integrated_Project_Folder__c> dummyIPF = new List<Integrated_Project_Folder__c>();
        BlockDeleteHelper.blockIPFRemove(dummyIPF);
        BlockDeleteHelper.blockJobRemove(listJobbbbbb);
        FS_Account__c fa = new FS_Account__c();
        System.runAs(userRecord){
            Insert fa;
        }
        listFAccount.add(fa);
        BlockDeleteHelper.blockFSAccountremove(listFAccount, 'User');
        //BlockDeleteHelper.blockFSAccountremove(listFAccount, 'User');
        RecordType bidrctype = [Select ID, Name From RecordType Where sObjectType = 'Bid__c' Limit 1];
        Bid__c bigbid = new Bid__c();
        System.RunAs(userRecord){
            //Insert bigbid;
        }
        RecordType Catalogrctype = [Select ID, Name From RecordType Where sObjectType = 'Service_Catalog__c' Limit 1];
        Service_Catalog__c catalog = TestUtilities.getSeriveCatalogDetails(Catalogrctype.Id);
        
        Service_Catalog__c bidResponseTemplate;
        Service_Catalog__c bidRequestTemplate;
        
        System.RunAs(userRecord){
           // Insert catalog;
            
            bidResponseTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidResponseTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidResponseTemplate.Template_Type__c = 'Bid Response Form';
			insert bidResponseTemplate;
	
		    bidRequestTemplate = TestUtilities.getSeriveCatalogDetails(recordMapId.get('Service_Catalog__c-Bid Template'));
			bidRequestTemplate.Template_Usage_Scope__c = 'Internal User Enters Cost Information;Supplier Enters Cost Information;Quick Estimate Entry';
			bidRequestTemplate.Template_Type__c = 'Bid Request';
			insert bidRequestTemplate;
        } 
        
        Bid__c bidrecord = TestUtilities.getCostComponentDetails(jobbbbbb.Id, bidRequestTemplate.id, bidResponseTemplate.Id, bidrctype.Id, bigbid.Id);
        System.RunAs(userRecord){
            bidrecord.Cost_Component_Status__c = 'good';
            bidrecord.Supplier_Bid_Request_Status__c = 'good';
            bidrecord.Bid_Round_Status__c = 'good';
            Insert bidrecord;
        } 
        List<Bid__c> listCostComponents = new List<Bid__c>();
        listCostComponents.add(bidrecord);
        List<Bid__c> dummycmp = new List<Bid__c>();
        
        BlockDeleteHelper.blockCostComponentsremove(listCostComponents);
        BlockDeleteHelper.blockCostComponentsremove(dummycmp);
        BlockDeleteHelper.blockAccountremove(upplierlist, 'Good');
        BlockDeleteHelper.blockAccountremove(upplierlist, 'Good');
        BlockDeleteHelper.blockAccountremove(clienlist, 'Good');
        BlockDeleteHelper.blockAccountremove(clienlist, 'Good');
        Job_Asset__c jobAssetg = TestUtilities.getDeliverableDetails();
        System.RunAs(userRecord){
            Insert jobAssetg;
        }    
        Job_Jacket_Deliverable__c jg = TestUtilities.getJobJacketDeliverables(jobbbbbb.Id, jobAssetg.Id);
        System.RunAs(userRecord){
            Insert jg;
        }    
        List<Job_Jacket_Deliverable__c> listJobdeliverables = new List<Job_Jacket_Deliverable__c>();
        listJobdeliverables.add(jg);
        BlockDeleteHelper.blockJobdeliverableRemove(listJobdeliverables);
        OPS_Asset__c opsAsseg = TestUtilities.getAssetDetails(jobAssetg.Id);
        System.RunAs(userRecord){
            Insert opsAsseg;
        }
        List<OPS_Asset__c> listAsseg = new List<OPS_Asset__c>();
        listAsseg.add(opsAsseg);
        BlockDeleteHelper.blockAssetRemove(listAsseg);
        Contact con = TestUtilities.getContactDetails(clientaccountRecord.Id, 'Test');
        System.RunAs(userRecord){
            Insert con;
        } 
        List<Contact> listContac = new List<Contact> ();
        listContac.add(con);
        BlockDeleteHelper.blockContactremove(listContac, clienlist, 'User');
    }
}
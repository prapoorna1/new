@isTest
public class AssetRemovaltest {
    public static testMethod void testblockAssegRemove()
    {        
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
        Map<String,Id> recordMapId=new map<String,Id>();
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType];
        for(RecordType recordType1:recordTypeList){
            recordMapId.put(recordType1.SobjectType+'-'+recordType1.Name,recordType1.Id);
        }
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
        
        Account accAgencyLegalEntity=TestUtilities.getAccountAgencyLegalEntityDetails('ALETest ',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        Account accClientLegalEntity=TestUtilities.getAccountClientLegalEntityDetails('CLETest',null,recordMapId.get('Account-Legal Entity'),UserInfo.getUserId());
        System.RunAs(userRecord) {
            insert accAgencyLegalEntity;
            insert accClientLegalEntity;
        }
        
        Job_Jacket__c jobbbbbb = TestUtilities.getJobDetail(ipf.Id,accountRecord.Id, accAgencyLegalEntity.Id, accClientLegalEntity.Id);
        System.RunAs(userRecord) {
            Insert jobbbbbb;
        }
        Job_Asset__c jobAssetg = TestUtilities.getDeliverableDetails();
        System.RunAs(userRecord){
            Insert jobAssetg;
        }    
        Job_Jacket_Deliverable__c jg = TestUtilities.getJobJacketDeliverables(jobbbbbb.Id, jobAssetg.Id);
        System.RunAs(userRecord){
            Insert jg;
        }
        OPS_Asset__c opsAsseg = TestUtilities.getAssetDetails(jobAssetg.Id);
        System.RunAs(userRecord){
            Insert opsAsseg;
        }
        
        System.RunAs(userRecord){
            delete opsAsseg;
        }
    }
}
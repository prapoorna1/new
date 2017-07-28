public with sharing class BidResponseExportController {
    public String fileName{get;set;}
    public List<Bid__c> bidResonses{get;set;}
        
    public String xlsHeader {
         get {
             String strHeader = '';
             strHeader += '<?xml version="1.0"?>';
             strHeader += '<?mso-application progid="Excel.Sheet"?>';
             return strHeader;
         }
     }
     
    public BidResponseExportController(){
        fileName = 'txt/xml#JobDetails';
        fetchListValues();
    }
    private void fetchListValues(){            
        //String jobId = ApexPages.currentPage().getParameters().get('recId');
        //System.debug('Jbo ID ##### ' + jobId);
        bidResonses = [ SELECT Parent_Bid_Process_Id__c, Name_ID__c, Supplier_Bid_Request_Status__c, Component_Name__c, Bidding_Round__c, Parent_Account_Name__r.Name, Bid_Template__c FROM Bid__c LIMIT 10 ];

        //System.debug('Jbo Products ##### ' + jobProducts );
    }
 
}
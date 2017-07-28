public with sharing class BidRoundComparisonBySupplierController {

public String roundList { get; set; }
public List<String> accountList{get;set;}
public List<List<String>> lineItems{get; set;}
public String supplierHeader{get;set;}
public Bid__c parentBid{get;set;}
public Integer responseCount{get;set;}

public BidRoundComparisonBySupplierController(){
    fetchAccountList();
}

public void fetchAccountList(){
    Map<String,String> bidParams = ApexPages.currentPage().getParameters();    
    List<ID> bidIds = new List<ID>();
    
    for( String key: bidParams.keySet() ){
        //System.debug('Params ##### ' + key + ' --- ' + bidParams.get( key ) );
        if( key.startsWith( 'bidId' ) ) {
            bidIds.add( bidParams.get( key ) );
        }            
    } 
    if( !bidIds.isEmpty() ){
       
        //Fetch all the supplier bid for the given bid which makes the columns of the table
        List<Bid__c> accountNames = [SELECT Parent_Bid_Round__c, Name_ID__c, Supplier_Bid_Request_Status__c, Component_Name__c, Bidding_Round__c, Parent_Account_Name__r.Name, Bid_Template__c FROM Bid__c WHERE RecordType.DeveloperName = 'Supplier_Bid' AND Id IN : bidIds ];
     
        if( accountNames != NULL && !accountNames.isEmpty()){         
            parentBid = accountNames[ 0 ];
            supplierHeader = '';
            //Fetch all the line items associated to Service Catalog( Bid Template ) which makes the rows of the table
            List<Bid_Line_Item__c> bidTemplateItems = [SELECT Bid_ID__c, Bid_ID__r.Parent_Account_Name__c, Name__c, Sort__c, Name_ID__c, Total__c FROM Bid_Line_Item__c WHERE Type__c = 'Line Item' AND Bid_ID__c =: accountNames[0].Id AND Bid_ID__r.RecordType.DeveloperName ='Supplier_Bid' ORDER BY Sort__c];    
            //Fetch all the Service Catalog Line Items associated the Bid Templates for all Bids which makes the cell values of the table
            List<Bid_Line_Item__c> itemList = [SELECT Bid_ID__c,Bid_ID__r.Parent_Account_Name__c, Name__c, Sort__c, Name_ID__c, Total__c FROM Bid_Line_Item__c WHERE Type__c = 'Line Item' AND Bid_ID__c IN :bidIds AND Bid_ID__r.RecordType.DeveloperName ='Supplier_Bid' ORDER BY Sort__c, Bid_ID__c];
            
            AggregateResult[] supplierResponse = [SELECT COUNT( Parent_Bid_Round__c ) resCount FROM Bid__c WHERE RecordType.DeveloperName = 'Supplier_Bid' AND Parent_Bid_Round__c =: parentBid.Parent_Bid_Round__c];
            responseCount = (Integer) supplierResponse[ 0 ].get('resCount');
            lineItems = new List<List<String>>();
       
            accountList = new List<String>();
            List<Double> itemTotal = new Double[ accountNames.size() ];
            Double bidTotal;
            accountList.add( 'Item#' );        
            accountList.add( 'Item Name' );
    
            Integer rowIdx = 0;
            //Preparing the table rows and the firs two column values
            for( Bid_Line_Item__c itemRec : bidTemplateItems ){
                if( itemRec.Name__c != NULL ){
                    lineItems.add( new List<String>() );
                    lineItems[rowIdx].add( itemRec.Sort__c + '' );
                    lineItems[rowIdx].add( itemRec.Name__c );
                    rowIdx++;
                }
            }
            lineItems.add( new List<String>() ); // Adding the additional last row to show the supplier total   
            lineItems[ rowIdx ].add( '' );
            lineItems[ rowIdx ].add( 'Total' );
            
            for( Bid__c actRec: accountNames ){
                accountList.add( actRec.Parent_Account_Name__r.Name );// Prepare column header with supplier name 
                supplierHeader += actRec.Parent_Account_Name__r.Name + ',';
                Integer rowNum = 0;
                bidTotal = 0;
                for( Bid_Line_Item__c item : itemList ){
                    if( item.Name__c != NULL && item.Bid_ID__r.Parent_Account_Name__c == actRec.Parent_Account_Name__c  ){
                        if( item.Total__c == NULL ) item.Total__c = 0;
                        lineItems[ rowNum ].add( '' + item.Total__c );
                        bidTotal += item.Total__c;
                        rowNum++;
                        if( rowNum == rowIdx ) break;//TODO - Once confirm all the customer bids has same number of items, we can delete this line
                    }
                }
                lineItems[ rowNum ].add( '' + bidTotal );
            }
            supplierHeader = supplierHeader.subString(0, (supplierHeader.length() -1 ) );
        }
    }
}
}
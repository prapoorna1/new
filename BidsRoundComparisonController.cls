public with sharing class BidsRoundComparisonController {
public List<String> roundList{get;set;}
public List<List<String>> lineItems{get; set;}
public String supplierHeader{get;set;}
public Bid__c parentBid{get;set;}
public Integer responseCount{get;set;}

public BidsRoundComparisonController(){
    fetchAccountList();
}
public void fetchAccountList(){
    String supplierId = ApexPages.currentPage().getParameters().get('supId');
    String bidId = ApexPages.currentPage().getParameters().get('bidId');
    if( supplierId != NULL && bidId!= NULL ){       
        //Fetch all the supplier bid for the given bid which makes the columns of the table
        List<Bid__c> supplierBids = [SELECT Id,Name, Parent_Bid_Round__c,Parent_Bid_Round__r.Bidding_Round__c , Parent_Bid_Round__r.Bid_Round_Status__C,Name_ID__c, Supplier_Bid_Request_Status__c,Due_date__c, Component_Name__c, Bidding_Round__c, Parent_Account_Name__r.Name, Bid_Template__c FROM Bid__c WHERE RecordType.DeveloperName = 'Supplier_Bid' AND Parent_Bid_Round__r.Parent_Bid_Process_Id__c =: bidId AND Parent_Account_Name__c =: supplierId and Is_Invitation_Sent__c=true ORDER BY Parent_Bid_Round__r.Bidding_Round__c];
        AggregateResult[] supplierResponse = [SELECT MAX(Bidding_Round__c) roundMax FROM Bid__c WHERE RecordType.Name = 'Supplier Bid Request' AND Parent_Bid_Round__c =: bidId AND Parent_Account_Name__c =: supplierId ];
        if( supplierBids != NULL && !supplierBids.isEmpty() ){
            supplierHeader = supplierBids[0].Parent_Account_Name__r.Name;
            parentBid = supplierBids[0];            
            roundList = new List<String>();
            lineItems = new List<List<String>>();
            Double bidRounds = (Double) supplierResponse[ 0 ].get('roundMax');
            List<Bid_Line_Item__c> bidTemplateItems = [SELECT Bid_ID__r.Bidding_Round__c,Bid_ID__c, Bid_ID__r.Parent_Account_Name__c, Name__c, Sort__c, Name_ID__c, Total__c FROM Bid_Line_Item__c WHERE Type__c = 'Summary' AND Bid_ID__c =: supplierBids[0].Id AND Bid_ID__r.RecordType.DeveloperName ='Supplier_Bid' ORDER BY Sort__c ];              
            List<Bid_Line_Item__c> itemList = [SELECT Bid_ID__r.Parent_Bid_Round__r.Bidding_Round__c,Bid_ID__c,Bid_ID__r.Parent_Account_Name__c, Name__c, Sort__c, Name_ID__c, Total__c FROM Bid_Line_Item__c WHERE Type__c = 'Summary' AND Bid_ID__r.Parent_Bid_Round__r.Parent_Bid_Process_Id__c  =: bidId AND Bid_ID__r.Parent_Account_Name__c =: supplierId ORDER BY Sort__c, Bid_ID__r.Bidding_Round__c ];            
            Decimal bidTotal;
            roundList.add( 'Item#' );        
            roundList.add( 'Item Name' );    
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
            for( Bid__c bidRec : supplierBids ){
                roundList.add( 'Response for Bid Round #' + bidRec.Parent_Bid_Round__r.Bidding_Round__c);// Prepare column header with supplier name                 
                Integer rowNum = 0;
                bidTotal = 0;
                for( Bid_Line_Item__c item : itemList ){
                    if( item.Name__c != NULL && item.Bid_ID__r.Parent_Bid_Round__r.Bidding_Round__c == bidRec.Parent_Bid_Round__r.Bidding_Round__c ){
                        if( item.Total__c == NULL ) item.Total__c = 0;
                        lineItems[ rowNum ].add( '' + item.Total__c );
                        bidTotal += item.Total__c;
                        rowNum++;
                        if( rowNum == rowIdx ) break;//TODO - Once confirm all the customer bids has same number of items, we can delete this line
                    }
                }
                if(rowNum!=0){
                    lineItems[ rowNum ].add( '' + bidTotal.setScale(2) );
                }
            }  
        }            
    }
}
}
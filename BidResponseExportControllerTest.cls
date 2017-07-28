@isTest
public with sharing class BidResponseExportControllerTest {
    @isTest(SeeAllData=true)
    public static void testFetchListValues(){
        BidResponseExportController testRec = new BidResponseExportController();
        String test = testRec.XlsHeader;
    }
}
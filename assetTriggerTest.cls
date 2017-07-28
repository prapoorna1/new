/******************************************************************************** 
Name:  assetTriggerTest
Copyright © 2015  Omnicom Group
================================================================= 
================================================================= 
Test class for assetTriggerTest class
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    A Soundararaja      02/15/15      INITIAL DEVELOPMENT
*********************************************************************************/ 
@isTest
public with sharing class assetTriggerTest{

  @isTest(SeeAllData=false) 
  public static void test_assetTrigger(){
        Job_Asset__c deliverable=TestUtilities.getDeliverableDetails();
        insert deliverable;
        OPS_Asset__c asset=TestUtilities.getAssetDetails(deliverable.Id);
        insert asset;
        update asset;
        delete asset;
        undelete asset;
   }
   
 }
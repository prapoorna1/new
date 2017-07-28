/******************************************************************************** 
Name:  ApexSharing
Copyright © 2015  OmnicCom Group
================================================================= 
================================================================= 
ApexSharing class
=================================================================
================================================================= 
History  -------
VERSION  AUTHOR              DATE         DETAIL                
1.0-     A Soundararaja      1/12/15     INITIAL DEVELOPMENT
*********************************************************************************/ 
public class ApexSharing {	
	 /*******************************************************************
    Purpose     : This method will be executed during addition of job team members
    Parameters  :                 
    Returns     : void
    ********************************************************************/
	public static SObject generateShare(String objectName,Id recordId, Id userOrGroupId,String AccessLevel){
		String sObjectName = objectName.replace('__c','__Share');
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        SObject shareObj = t.newSObject();                          
        shareObj.put('ParentId', recordId);
        shareObj.put('UserOrGroupId', userOrGroupId);
        shareObj.put('AccessLevel', AccessLevel);
        return shareObj;
	}   
/*******************************************************************
    Purpose     : This method will be executed during Portal User creation
    Parameters  :                 
    Returns     : void
    ********************************************************************/
public static AccountShare manualShareAccount(Id recordId, Id userOrGroupId){
		AccountShare accShare=new AccountShare();
		accShare.AccountId = recordId;
		accShare.UserOrGroupId = userOrGroupId;
		accShare.AccountAccessLevel=OmnicomConstant.WRITE_ACCESS_LEVEL;
		accShare.OpportunityAccessLevel=OmnicomConstant.READ_ACCESS_LEVEL;
		accShare.ContactAccessLevel=OmnicomConstant.WRITE_ACCESS_LEVEL;
		accshare.CaseAccessLevel=OmnicomConstant.READ_ACCESS_LEVEL;
		accShare.RowCause=OmnicomConstant.ROWCLAUSE_MANUAL;
		return accShare;
}
}
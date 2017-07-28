@isTest
(SeeAllData=false)
public class accountInsertTest{ 
Private static testMethod void TestgroupInsert(){
    string grpname;
    
		Map<String,Id> recordMapId=new map<String,Id>(); //creating Map variable
        List<RecordType> recordTypeList=[Select Id,Name,SobjectType from RecordType]; //fetching all recordtypes from Recordtype object
        for(RecordType recordType:recordTypeList){
            recordMapId.put(recordType.SobjectType+'-'+recordType.Name,recordType.Id);//filtering recordtype with objects and adding with Id.
        }
    User userRec=TestUtilities.getTestUser(TestUtilities.getAdminProfile(),TestUtilities.getUserRole());
    userRec.username='Test1@Omnicom.com';
    insert userRec;
    
    Recordtype rt = new Recordtype();
    rt= [select id ,name from Recordtype where name=:'OMCRepEnt' LIMIT 1];
    
    Account act1 = new Account();
    act1.name='test2';
     act1.RecordTypeID=rt.id;
        act1.Name='name';
       // act1.Parentid=Parentaccount;
       //act1.OwnerId=userId;
    System.runAs(userRec){
    insert act1;   
    }
//Account act=TestUtilities.getAccountDetails('test',act1.id,recordMapId.get('Account-OMCRepEnt'),UserInfo.getUserId());
	Account act = new Account();
    act.ParentId=act1.Id;
    act.Name='name2';    
    System.runAs(userRec){
    insert act;   
    }
Map<id,Account> acMap =  new Map<Id,Account>();
acMap.put(act.id,act);
    Map<id,id> accwithparen= new Map<id,id>();
   
    accwithparen.put(act.Id,act.parentId);
    accountInsert.runOnce = false;    
        system.debug(userRec);
        System.runAs(userRec){
        	    UserRole r = new UserRole(name = 'TEST ROLE');
                insert r;
        }
    	List<group> groupList = new List<group>();
        group gg = new group();
        gg.name='name2';            
        groupList.add(gg);
    	System.RunAs(userRec){
            insert groupList;
        }
    	GroupMember gp = new GroupMember(
    	GroupId = gg.Id,
    	UserOrGroupId = userRec.Id
        );
    	System.RunAs(userRec){
            insert gp;
        }
    // List<accountShare> accShareList = new List<accountShare>();
        //AccountShare share = new AccountShare();
        //share.AccountId= act.Id;    
        //share.UserOrGroupId= gg.id;
       // share.AccountAccessLevel= 'Edit';
        //share.OpportunityAccessLevel= 'Edit';
   // System.RunAs(userRec){
      //  insert share;
    //}
    	System.RunAs(userRec){
        		accountInsert.groupInsert(acMap);
        }
    System.RunAs(userRec){
                    Delete act;
    }
   					Map<id,Account> acMap1 =  new Map<Id,Account>();
					acMap1.put(act.id,act);
    System.RunAs(userRec){
				accountInsert.groupDelete(acMap1);
        }
    accountInsert outerObj = new accountInsert();
	accountInsert.stringHelper obj = new accountInsert.stringHelper('gVar', 'childGrp');
 	List<String> listGrpMembers = new List<String>();
    
    //GroupMember gpMembers = [SELECT Id, GroupId FROM GroupMember Limit 1];
    accountInsert.stringHelper sh = new accountInsert.stringHelper(gp.GroupId,gp.UserOrGroupId); 
    listGrpMembers.add(JSON.serialize(sh));

    if(Test.isRunningTest())
    {
        accountInsert.grpMemberInsert(listGrpMembers);
    }
}
}
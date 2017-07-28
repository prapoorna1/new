/******************************************************************************** 
Name:  AdPortalSecurity
Copyright © 2016  Omnicom Group 

================================================================= 
================================================================= 
This class is used to do Create public Groups ,Manage MemberShip,Add Share records for each object related to jobs
=================================================================
================================================================= 
History  
-------
VERSION  AUTHOR              DATE         DETAIL                
1.0 -    SOUNDARARAJA A     06/28/2016   INITIAL DEVELOPMENT
*********************************************************************************/
public  class AdPortalSecurity {
    
    // the following constant is used to create group name by replacing reference code from job
    public static final String JOB_REFERENCECODE_READ='JOB_REFERENCECODE_READ';
    public static final String JOB_REFERENCECODE_EDIT='JOB_REFERENCECODE_EDIT';
    
    //Based on this variable we will be recalulating entire share rules (Group creation, ManageMembership and recalculate share rules)
    public Boolean isCompleteSharingRuleCalculation { get ; set; }
    //This variable is used to remove unnecessary share records if present
    public Boolean isSynchronize { get; set; }
    
    //holds set of job ids
    public set<Id> jobSet { get; set; }
    //holds list of job records
    public list<Job_Jacket__c> jobList { get; set; }
    //holds list of exising groups
    public list<Group> existingGroupList { get; set; }
    
    //specific variables for creating Groups for job which are created newly
    public map<Id,String> pendingGroupEditJobIdMap { get; set; }
    public map<Id,String> pendingGroupReadJobIdMap { get; set; }
    public map<String,Job_Jacket__c> groupJobMap { get; set; }
    
    //variables for recalculating Sharing rules
    public map<String,map<Id,set<Id>>> objectNameRecordJobIdMap { get; set; }
    public map<Id,set<Id>> objectJobIdMap { get; set; }
    
    //For Share records insertion 
   // public  newGroupList { get; set; }
    public map<Id,Group> existingGroupMap { get; set; }
    
    public set<String> userAccessLevelParentIdSet { get; set; }
    public map<String,Id> userAccessLevelParentGroupIdMap { get; set; }
    map<Id,map<Id,Sobject>> groupObjectShareMap { get; set; }
    
    //relates groupname and jobs
    map<String,Id> groupNameJobIdMap { get; set; }
    //relates groupname and its group Id
    map<String,Id> groupNameIdMap { get; set; }
    
    public set<Id> parentIdSet { get; set; }
    //this string will be used to indicate for which sharing record we need to query
    public String QUERYOBJECT { get; set; }
    
    //holds set of record ids (job,jobteam)
    public set<Id> recordIdSet { get; set; }
    
    //set of pending jobs
    public set<Id> pendingJobs { get; set; }
    
    
    public  AdPortalSecurity() {
         
         //getting exisint share records
        userAccessLevelParentIdSet = new set<String>();
        
        isCompleteSharingRuleCalculation = false;
        isSynchronize = false;
        
        jobSet = new set<Id>();
        recordIdSet = new set<Id>();
        groupNameJobIdMap = new map<String,Id>();
        groupNameIdMap =  new map<String,Id>();
        groupObjectShareMap = new map<Id, map<Id,Sobject>>();
        objectNameRecordJobIdMap = new map<String,map<Id,set<Id>>>();
        pendingJobs = new set<Id>(); 
        
    }
    
   // this constructor is used to intialize recordId for groupshare record insertion for each object
    public AdPortalSecurity(set<Id> tempJobSet){
        
        this();
        //jobSet = tempJobSet;
        recordIdSet = tempJobSet;
        
    
    }
    
    
    // this method is called to order to execute the entire adportal security logic
    public AdPortalSecurity initialize(){
        
        isCompleteSharingRuleCalculation=true;
        
        return this;
    }
    
    // this method is called before executing any sharing calculation methods in order to add,remove and synchronize share records and group members
    public AdPortalSecurity setSynchronize(){
        
        isSynchronize = true;
        if(isSynchronize){
            jobSet.addAll(recordIdSet);
        }
        return this;
    }
    
    // this method is called before executing any sharing calculation methods in order to add,remove and synchronize share records and group members based on the values based
    public AdPortalSecurity setSynchronize(Boolean isSyn){
        
        isSynchronize = isSyn;
        if(isSynchronize){
            jobSet.addAll(recordIdSet);
        }
        return this;
    }
    
    //setting the job ids for recalculating entire share rules or removing any share records or removing any group members we need to intialize this
    public AdPortalSecurity setJob(set<Id> tempJobSet){
        
        jobSet=tempJobSet;
        
        return this;
    }
    //settings jobdeliverables ids and job ids for adding or removing share records for deliverable records
    public AdPortalSecurity setJobDeliverable(list<Job_Jacket_Deliverable__c> jobDeliverableList ){
        
        
        for(Job_Jacket_Deliverable__c jobDeliverable : jobDeliverableList ) {
            
           if(isSynchronize){
                jobSet.add(jobDeliverable.Job_Jacket__c);
           }
           
           recordIdSet.add(jobDeliverable.Id);
        }
        
        return this;
    }
    
 
    
    
    //this method is used to identify job ids for which IPF field is modified ( will be used to update the group members)
    public AdPortalSecurity setJob(list<Job_Jacket__c> jobList,map<Id,Job_Jacket__c> oldJobmap){
        
        if(jobList != NULL){
              for(Job_Jacket__c job : jobList){
                     
                    if(oldJobmap != NULL && oldJobmap.get(job.Id) != NULL){
                        
                        if(job.Integrated_Project_Folder__c !=  oldJobmap.get(job.Id).Integrated_Project_Folder__c){
                            jobSet.add(job.Id);
                        }
                        
                    }
            }
        }
        
        return this;
    }
    
    
    
     //this method is used to identify job team ids for which job team member access type is changed (will be used to update the group members )
    public AdPortalSecurity setJobTeam(list<Job_Team__c> jobTeamList,map<Id,Job_Team__c> oldJobTeamMap){
        
        for(Job_Team__c jobTeam : jobTeamList){
            
            if(oldJobTeamMap != NULL && oldJobTeamMap.get(jobTeam.Id) != NULL){
                
                if(jobTeam.Access_Type__c !=  oldJobTeamMap.get(jobTeam.Id).Access_Type__c ){
                    recordIdSet.add(jobTeam.Id);
                }
                
            }
        }
        
        return this;
    }
    
    //this method is used to identify job ids for which job team member is removed(will be used for Job team member removal)
    public AdPortalSecurity setJob(list<Job_Team__c> jobTeamList){
        
        for(Job_Team__c jobTeam : jobTeamList){
            
            jobSet.add(jobteam.Job_Jacket_ID__c);
        }
        
        return this;
    }
    
    /*******************************************************************
    Purpose     :  the method creates edit and read group for each job if the group doesn't exist for the job
    Parameters  :  
    Returns     : AdPortalSecurity 
    ********************************************************************/
    public AdPortalSecurity createPublicGroup(){
        
            //contains all groupnames existing as well as new groups
            set<String> groupDeveloperNameSet = new set<String>();
            //contains all group names and its assicated job for both exising as well as new groups
            map<String,Job_Jacket__c> groupJobMap = new map<String,Job_Jacket__c>();
            
            //contains new groups thats need to be added
            list<Group> newGroupList = new list<Group>();
            
            //map contains new read groups and its associated job
            map<Id,String> pendingGroupReadJobIdMap = new map<Id,String>();
             //map contains new edit groups and its associated job
            map<Id,String> pendingGroupEditJobIdMap = new map<Id,String>();
            
            //retrieve list of job records based on jobSet for group names
            jobList = [SELECT Group_Edit_DeveloperName__c, Group_Read_DeveloperName__c,Reference_Code__c FROM Job_Jacket__c where id=:jobSet];
            
            //collecting the group names and its associated job
            for(Job_Jacket__c job : jobList){
                
                   //getting job group edit name for which groups are not being created.
                    if( job.Group_Edit_DeveloperName__c != NULL ){
                        
                          groupDeveloperNameSet.add(job.Group_Edit_DeveloperName__c);
                        
                    }
                    else {
                        
                        String groupEditDeveloperName = JOB_REFERENCECODE_EDIT.replace('REFERENCECODE', job.Reference_Code__c);
                        groupDeveloperNameSet.add(groupEditDeveloperName);
                        
                    }
                    
                     //getting job group read name for which groups are not being created.
                    if( job.Group_Read_DeveloperName__c != NULL ){
                        
                        //groupJobMap.put(job.Group_Read_DeveloperName__c,job);
                        groupDeveloperNameSet.add(job.Group_Read_DeveloperName__c);
                        
                    }
                    else {
                        
                        String groupReadDeveloperName = JOB_REFERENCECODE_READ.replace('REFERENCECODE', job.Reference_Code__c);
                        groupDeveloperNameSet.add(groupReadDeveloperName);
                        
                    }
            }
            //retrieving list of existing groups
            existingGroupMap = new map<Id,Group>( [ Select Id,DeveloperName from Group where DeveloperName =: groupDeveloperNameSet ] );
            
            //remove exiting groups in order create new groups for jobs
            for(Group g : existingGroupMap.values()){
                
                groupDeveloperNameSet.remove(g.DeveloperName);
                
            }
            
            //Creating Groups for the Jobs which doesn't have any group
            for(String groupName : groupDeveloperNameSet){
                
                Group newGroup = new Group();
                newGroup.Name = groupName.replace('_', '-');
                newGroup.DoesIncludeBosses=false;
                newGroupList.add(newGroup);
                
            }
            
            if( (newGroupList != NULL) && (newGroupList.size()> 0) ){
                
                Database.insert( newGroupList,false);
                
            }
            return this;
    }    
    
   /*******************************************************************
    Purpose     :  This method is used to add job team members to the exisiting groups based on the access type
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/
    
    public AdPortalSecurity manageGroupMembership(){
        
        //combinations of groupName ,UserId and its related Job Team
        map<String,Job_Team__c> groupNameJobTeamMap = new map<String,Job_Team__c>();
        //collecting list of groupname for jobs associated to Job Team
        set<String> groupDeveloperNameSet = new set<String>();
        
        //list of job team members for which group memberships needs to be updated based on the access type
        list<Job_Team__c> jobTeamList = [SELECT Job_Jacket_ID__c,Job_Jacket_ID__r.Reference_Code__c,Access_Type__c,User_ID__c,Job_Jacket_ID__r.Group_Edit_DeveloperName__c,Job_Jacket_ID__r.Group_Read_DeveloperName__c FROM Job_Team__c WHERE Id =: recordIdSet or Job_Jacket_ID__c =: jobSet];
        
        
        //looping through the job team list to collect and map group names and its associated job team 
        for(Job_Team__c jobTeam : jobTeamList){
            
                 //checking wheather jobteam  has edit group name 
                 if(jobTeam.Job_Jacket_ID__r.Group_Edit_DeveloperName__c != NULL){
                    
                    groupDeveloperNameSet.add(jobTeam.Job_Jacket_ID__r.Group_Edit_DeveloperName__c);
                    groupNameJobTeamMap.put(jobTeam.Job_Jacket_ID__r.Group_Edit_DeveloperName__c+jobTeam.User_ID__c,jobTeam);
                
                  }
                  else {
                        //temporary group name created and is used to check whether the group exist or not
                        String groupEditDeveloperName = JOB_REFERENCECODE_EDIT.replace('REFERENCECODE', jobTeam.Job_Jacket_ID__r.Reference_Code__c);
                        
                        groupDeveloperNameSet.add(groupEditDeveloperName);
                        groupNameJobTeamMap.put(groupEditDeveloperName+jobTeam.User_ID__c,jobTeam);
                        
                        //adding jobs for which groups are not being created
                        pendingJobs.add(jobTeam.Job_Jacket_ID__c);
                        
                 }
                 
                  //checking wheather jobteam  has read group name 
                 if(jobTeam.Job_Jacket_ID__r.Group_Read_DeveloperName__c != NULL){
                    
                       groupDeveloperNameSet.add(jobTeam.Job_Jacket_ID__r.Group_Read_DeveloperName__c);
                       groupNameJobTeamMap.put(jobTeam.Job_Jacket_ID__r.Group_Read_DeveloperName__c+jobTeam.User_ID__c,jobTeam);
                  }
                 else {
                        //temporary read group name is created and used to check whether the group exist or not
                        String groupReadDeveloperName = JOB_REFERENCECODE_READ.replace('REFERENCECODE', jobTeam.Job_Jacket_ID__r.Reference_Code__c);
                        
                        groupDeveloperNameSet.add(groupReadDeveloperName);
                        groupNameJobTeamMap.put(groupReadDeveloperName+jobTeam.User_ID__c,jobTeam);
                        
                        //adding jobs for which groups are not being created
                        pendingJobs.add(jobTeam.Job_Jacket_ID__c);
                    }
             
            
        }
        
        map<String,Id> groupNameIdMap = getGroupNameGroupIdMap(groupDeveloperNameSet);
        
        //retrieving list of exisitng group members
        list<GroupMember> groupMemberList=[SELECT Id, Group.DeveloperName, UserOrGroupId FROM GroupMember where Group.DeveloperName = : groupDeveloperNameSet];
        
        map<String,set<Id>> groupNameUserIdMap = new map<String,set<Id>>();
        map<String,GroupMember> groupMemberMap = new map<String,GroupMember>();
        
        //collecting all exisitng group member in a map for easy comparision
        for(GroupMember groupMember : groupMemberList){
            
            groupMemberMap.put(groupMember.Group.DeveloperName+groupMember.UserOrGroupId,groupMember);
            
        }
        list<GroupMember> removeGroupMemberList = new list<GroupMember>();
        
        
        //looping through the job teams to find appropriate groups based on the access type
        for(Job_Team__c jobTeam : jobTeamList){
            
                 String groupEditDeveloperName;
                 
                 if(jobTeam.Job_Jacket_ID__r.Group_Edit_DeveloperName__c != NULL){
                    
                      groupEditDeveloperName=jobTeam.Job_Jacket_ID__r.Group_Edit_DeveloperName__c;
                 }
                 else {
                    
                      groupEditDeveloperName = JOB_REFERENCECODE_EDIT.replace('REFERENCECODE', jobTeam.Job_Jacket_ID__r.Reference_Code__c);
                 }
                    
                String groupReadDeveloperName;
                
                if(jobTeam.Job_Jacket_ID__r.Group_Read_DeveloperName__c != NULL){
                    
                      groupReadDeveloperName=jobTeam.Job_Jacket_ID__r.Group_Read_DeveloperName__c;
                }
                 else {
                        groupReadDeveloperName = JOB_REFERENCECODE_READ.replace('REFERENCECODE', jobTeam.Job_Jacket_ID__r.Reference_Code__c);
                        
                }
              
              //retrieving existing member ship for the job team if present
              GroupMember adminGroupMember = groupMemberMap.get(groupEditDeveloperName+jobTeam.User_ID__c);
              GroupMember readGroupMember = groupMemberMap.get(groupReadDeveloperName+jobTeam.User_ID__c);
             
             if(adminGroupMember != NULL){
                     
                     //checking current access type and if it is viewer and removing the previous group member record and add it to  read group
                     if(jobTeam.Access_Type__c == 'Viewer'){
                                
                                set<Id> tempUserIdSet;
                                if( (groupNameUserIdMap != NULL ) && ( groupNameUserIdMap.get(groupReadDeveloperName) != NULL )){
                                    
                                    tempUserIdSet = groupNameUserIdMap.get(groupReadDeveloperName);
                                    
                                }
                                else {
                                    
                                    tempUserIdSet = new set<Id>();
                                }
                                tempUserIdSet.add(jobTeam.User_ID__c);
                                groupNameUserIdMap.put(groupReadDeveloperName,tempUserIdSet);
                                removeGroupMemberList.add(adminGroupMember);
                     }
                     
                     //checking current access type and if it is viewer and removing the previous group member record 
                     if((jobTeam.Access_Type__c == 'None')){
                        
                          removeGroupMemberList.add(adminGroupMember);
                          
                      }
             }
             
             if(readGroupMember != NULL){
                
                      //checking current access type and if it is Collaborator or Administrator and removing the previous group member record and add it to edit group
                     if((jobTeam.Access_Type__c == 'Collaborator' || jobTeam.Access_Type__c == 'Administrator')){
                                
                                set<Id> tempUserIdSet;
                                if( (groupNameUserIdMap != NULL) && ( groupNameUserIdMap.get(groupEditDeveloperName)!= NULL )){
                                    tempUserIdSet = groupNameUserIdMap.get(groupEditDeveloperName);
                                }
                                else {
                                    tempUserIdSet = new set<Id>();
                                }
                                tempUserIdSet.add(jobTeam.User_ID__c);
                                groupNameUserIdMap.put(groupEditDeveloperName,tempUserIdSet);
                                removeGroupMemberList.add(readGroupMember);
                                
                            
                                
                    }
                     //checking current access type and if it is Collaborator or Administrator and removing the previous group member record 
                    if((jobTeam.Access_Type__c == 'None')){
                        
                          removeGroupMemberList.add(readGroupMember);
                          
                      }
             }
             
             //if the job team member is new member or changed from 'None' to Collaborator or administrator or Viewer,then adding it to job team member based on access type
             if(adminGroupMember==NULL && readGroupMember == NULL) {
                
                   set<Id> tempUserIdSet;
                    //checking current access type and if it is Collaborator or Administrator and  add it to edit group
                    if((jobTeam.Access_Type__c == 'Collaborator' || jobTeam.Access_Type__c == 'Administrator')){
                       tempUserIdSet = new set<Id>();
                       if(groupNameUserIdMap != NULL && groupNameUserIdMap.get(groupEditDeveloperName) != NULL){
                            tempUserIdSet = groupNameUserIdMap.get(groupEditDeveloperName);
                       }
                       else {
                                    tempUserIdSet = new set<Id>();
                       }
                       tempUserIdSet.add(jobTeam.User_ID__c);
                       groupNameUserIdMap.put(groupEditDeveloperName,tempUserIdSet);
                      
                   } 
                 //checking current access type and if it is viewer and add it to read group
                  else if(jobTeam.Access_Type__c == 'Viewer'){
                    
                       tempUserIdSet = new set<Id>();
                       if(groupNameUserIdMap != NULL && groupNameUserIdMap.get(groupReadDeveloperName) != NULL){
                            tempUserIdSet=groupNameUserIdMap.get(groupReadDeveloperName);
                       }
                       else {
                            tempUserIdSet = new set<Id>();
                       }
                       tempUserIdSet.add(jobTeam.User_ID__c);
                       groupNameUserIdMap.put(groupReadDeveloperName,tempUserIdSet);
                   }
             }
             
              groupMemberMap.remove(groupEditDeveloperName+jobTeam.User_ID__c);
              groupMemberMap.remove(groupReadDeveloperName+jobTeam.User_ID__c);
              
        }
         
        list<GroupMember> gmList = new list<GroupMember>();
        
        //looping through the map list for which member needs to be added   
        for(String groupName : groupNameUserIdMap.keySet()){
             
             set<Id> userIdSet = groupNameUserIdMap.get(groupName);
             Id groupId = groupNameIdMap.get(groupName);
             
             if(groupId != NULL) {
                
                 for(Id userId : userIdSet){
                    
                     GroupMember gm = new groupMember();
                     gm.GroupId = groupId;
                     gm.UserOrGroupId = userId;
                     gmList.add(gm);
                     
                 }
             }
             
             
             
        }
        
        if( (gmList != NULL) && (gmList.size() > 0)){
            Database.insert( gmList,false);
        }
        //removing group members for which  Job team access type is 'none'
        if( (removeGroupMemberList != NULL) && (removeGroupMemberList.size() > 0) ){
            Database.delete( removeGroupMemberList,false);
        }
        
        //this logic is executed if the group has invalid group members or group member is deleted
        if(isSynchronize == true){
             if(groupMemberMap != NULL && groupMemberMap.size() > 0){
                Database.delete( groupMemberMap.values(),false);
              }
        }
       //this logic is executed if there are pending job for which group needs to be created
       if( (isCompleteSharingRuleCalculation == false) && (pendingJobs != NULL) && (pendingJobs.size() > 0) && !test.isrunningtest()){
             System.enqueueJob(new GroupHandlerAsyncExecution(pendingJobs));
       } 
       
       return this;
  }
    
    /*******************************************************************
    Purpose     :  this method is used to recalculate share rules for the record ids(bid,deliverable etc) passed
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/    
    public AdPortalSecurity recalculateSharingRules(){
        
            //getting group name and its job Id
            groupNameJobIdMap = getGroupNameJobMap(jobSet);
            //getting group Name and group ids
            groupNameIdMap = getGroupNameGroupIdMap(groupNameJobIdMap.keySet());
            //Associating job and its related group 
            map<Id,map<String,Id>> jobAccessLevelGroupMap = getJobAccessGroupMap(groupNameJobIdMap, groupNameIdMap);
           
           //looping through map which contains objects id and its related jobs and querying the existing share records for the objects
            for(String objectName : objectNameRecordJobIdMap.keySet()){
                    //getting objects ids and its related jobs
                    objectJobIdMap = objectNameRecordJobIdMap.get(objectName);
                    if(isSynchronize == true){
                        
                         if((groupNameIdMap != NULL) && (groupNameIdMap.size() > 0)){
                            
                            //object Name for which share records need to be retrieved
                            QUERYOBJECT = objectName;
                            getExistingShareRecords();
                         }
                            
                    }
                    else {
                            if((objectJobIdMap != NULL) && (objectJobIdMap.size() > 0)){
                                
                                //object Name for which share records need to be retrieved
                                QUERYOBJECT = objectName;
                                getExistingShareRecords();
                            }
                    }
           }
            
            List<Sobject> shareRecordList = new List<Sobject>();
            set<String> objectNameSet = new set<String>();
            
            objectNameSet.add('Integrated_Project_Folder__c');
            objectNameSet.add('Job_Asset__c');
            
            //Looping through map which contain objects(job,jobdeliverable,deliverabl,bid) and its records. this method will collects the share records thats need to be inserted or deleted
            for(String objectName : objectNameRecordJobIdMap.keySet()){
                //getting object records and its related job ids
               objectJobIdMap = objectNameRecordJobIdMap.get(objectName);
               
               //object ids
               for(Id parentId : objectJobIdMap.keySet()){
                       //looping through associated jobs for the objects ids as job deliverable and IPF have many to many relationship with jobs
                      for(Id  jobId : objectJobIdMap.get(parentId)){
                                 
                                 //checking this map which contains group ids based on access type for each job
                                 if((jobAccessLevelGroupMap != NULL) && (jobAccessLevelGroupMap.get(jobId) != NULL)){
                                            
                                             map<String,Id> accessLevelGroupIdMap = jobAccessLevelGroupMap.get(jobId);
                                             //looping through access level for each job
                                             for(String accessLevel : accessLevelGroupIdMap.keySet()){
                                                     //getting group ids for each access level and job id
                                                     Id groupId = accessLevelGroupIdMap.get(accessLevel);
                                                     
                                                     //adding or removing share records for which group id is present
                                                     if(groupId != NULL){    
                                                        
                                                             if(userAccessLevelParentIdSet.contains((String)parentId +(String)groupId+(String)accessLevel)==false){
                                                                
                                                                     Sobject shareRecord=(Sobject)ApexSharing.generateShare(objectName,parentId, groupId,accessLevel);
                                                                     if(shareRecord != NULL){
                                                                        shareRecordList.add(shareRecord);
                                                                     }
                                                                 
                                                             }
                                                             else {
                                                                
                                                                    if(objectNameSet.contains(objectName)){
                                                                           
                                                                                //this code must be executed for job deliverable and IPF
                                                                                if(groupObjectShareMap != NULL && groupObjectShareMap.get(groupId) != NULL){
                                                                                    
                                                                                        map<Id,Sobject> objectShareMap = groupObjectShareMap.get(groupId);
                                                                                        
                                                                                        if( objectShareMap != NULL && objectShareMap.get(parentId)!= NULL){
                                                                                            
                                                                                            objectShareMap.remove(parentId);
                                                                                            groupObjectShareMap.put(groupId,objectShareMap);
                                                                                            
                                                                                        }
                                                                                }
                                                                    }
                                                             
                                                             }
                                                     }
                                                     else {
                                                        //pending jobs for which groups has not been created
                                                        pendingJobs.add(jobId);
                                                     }
                                             }
                                    }
                                    
                      }
                }
            }
            
            system.debug('# shareRecordList '+shareRecordList);
            
            if( (shareRecordList != NULL) && (shareRecordList.size()>0) ){
                
                 insert shareRecordList;
            }
            
            //this logic will be called only if object records(job deliverable ,IPF) are deleted where many to many relationship is there
            if(isSynchronize == true){
                
                    if( (groupObjectShareMap != NULL) && (groupObjectShareMap.size() >  0)){
                            //need to delete the records
                        list<Sobject> shareList = new list<Sobject> ();
                        
                        for(Id groupId: groupObjectShareMap.keySet()){
                            
                           map<Id,Sobject> objectShareMap = groupObjectShareMap.get(groupId);
                           
                             for(Sobject share : objectShareMap.values() ){
                                
                                  shareList.add(share);
                             }
                        }
                        
                        
                        if( (shareList != NULL) && (shareList.size () > 0)){
                            delete shareList;
                        }
                    }
                    
                    
              }
              
              //this logic is executed if there are pending job for which group needs to be created
               if( (isCompleteSharingRuleCalculation == false) && (pendingJobs != NULL) && (pendingJobs.size() > 0) && !test.isrunningtest()){
                       System.enqueueJob(new GroupHandlerAsyncExecution(pendingJobs));
               }
              
              return this;
    }
    
    /*******************************************************************
    Purpose     :  This method will be executed to job group fields once group is created for that particular job
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/
    
    public AdPortalSecurity updateJobGroupFields() {
          
            map<Id,String> pendingGroupReadJobIdMap = new map<Id,String>();
            map<Id,String> pendingGroupEditJobIdMap = new map<Id,String>();
            
            list<Job_Jacket__c> updatedJobList = new list<Job_Jacket__c>();
            //retrieve list of job records based on jobSet for group names
            jobList = [SELECT Group_Edit_DeveloperName__c, Group_Read_DeveloperName__c,Reference_Code__c FROM Job_Jacket__c where id=:jobSet];
            
            //collecting the group names and its associated job
            for(Job_Jacket__c job: jobList){
                
                    if(job.Group_Edit_DeveloperName__c == NULL){
                    
                        String groupEditDeveloperName = JOB_REFERENCECODE_EDIT.replace('REFERENCECODE', job.Reference_Code__c);
                        pendingGroupEditJobIdMap.put(job.Id,groupEditDeveloperName );
                    }
                    
                    if(job.Group_Read_DeveloperName__c == NULL){
                        
                        String groupReadDeveloperName = JOB_REFERENCECODE_READ.replace('REFERENCECODE', job.Reference_Code__c);
                        pendingGroupReadJobIdMap.put(job.Id, groupReadDeveloperName );
                    }
            }
           
         for(Job_Jacket__c job: jobList){
                
                   if(pendingGroupReadJobIdMap != NULL && pendingGroupReadJobIdMap.get(job.Id) != NULL){
                        job.Group_Read_DeveloperName__c = pendingGroupReadJobIdMap.get(job.Id);
                   }
                   
                   if(pendingGroupEditJobIdMap != NULL && pendingGroupEditJobIdMap.get(job.Id) != NULL){
                        job.Group_Edit_DeveloperName__c = pendingGroupEditJobIdMap.get(job.Id);
                   }
                   updatedJobList.add(job);
            }
            
            if( updatedJobList != NULL && updatedJobList.size()>0){
                update updatedJobList;
            }
            
            return this;
    }
    
    /*******************************************************************
    Purpose     :  getting list of existing share records for the secified objects
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/
    public AdPortalSecurity getExistingShareRecords(){

        
        if( ( groupNameIdMap != NULL && groupNameIdMap.size() > 0 ) ||  ( objectJobIdMap != NULL && objectJobIdMap.size() > 0 )){
            
       
                   String SOQL;
                   if(isSynchronize == true ){
                    
                          SOQL = 'SELECT Id,AccessLevel,ParentId,UserOrGroupId FROM Object__Share WHERE UserOrGroupId IN '+ quoteKeySet(groupNameIdMap.values());
                   
                    }
                    else {
                        
                          SOQL = 'SELECT Id,AccessLevel,ParentId,UserOrGroupId FROM Object__Share WHERE ParentId IN '+quoteKeySet(objectJobIdMap.keySet());
                    }
                    
                    SOQL=SOQL.replace('Object__Share',QUERYOBJECT.replace('__c','__Share'));
                     system.debug('#SOQL '+SOQL);
                    List<Sobject>  existingShareRecords = Database.query(SOQL);
                    
                    for(Sobject s:existingShareRecords){ 
                         
                            userAccessLevelParentIdSet.add(String.valueOf(s.get('ParentId'))+String.valueOf(s.get('UserOrGroupId'))+s.get('AccessLevel'));
                            map<Id,Sobject> objectShareMap = new map<Id,Sobject> ();
                            if(groupObjectShareMap != NULL && groupObjectShareMap.get((Id)s.get('UserOrGroupId'))!= NULL){
                                
                                objectShareMap=groupObjectShareMap.get((Id)s.get('UserOrGroupId'));
                            }
                            else {
                                
                                objectShareMap= new map<Id,Sobject> ();
                            }
                            
                            objectShareMap.put((Id)s.get('ParentId'),s);
                            groupObjectShareMap.put((Id)s.get('UserOrGroupId'),objectShareMap);
                    }
                    
            }
            return this;
    }
        /*******************************************************************
    Purpose     :  this method is used to retrieve object (job,jobdeliverble,bids,etc) records for all objects
    Returns     : getJobRelatedAllRecord
    ********************************************************************/
    
    public AdPortalSecurity getJobRelatedAllRecord(){
         
    
          
         getJobRecords();
         getIPFRecords();
         getDeliverableRecords();
         getBidRecords();
         
         return this;
    }
    
    
   /*******************************************************************
    Purpose     :  This method will be executed to job records based on records ids passed
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/
    public AdPortalSecurity getJobRecords(){
        
          //Getting list of job Records ids
         list<Job_Jacket__c> jobList = [SELECT Id FROM Job_Jacket__c where Id =: jobSet];
         map<Id,set<Id>> objectJobIdMap =new map<Id,set<Id>>();
         
         for(Job_Jacket__c job : jobList){
            
            set<Id> tempJobSet = new set<Id>();
            tempJobSet.add(job.Id);
            objectJobIdMap.put(job.Id,tempJobSet);
         }
         if(objectJobIdMap != NULL && objectJobIdMap.size() > 0){
            
             objectNameRecordJobIdMap.put('Job_Jacket__c',objectJobIdMap);
             
         }
         
         return this;
    }
    
   /*******************************************************************
    Purpose     :  This method will be executed to IPF records based on records ids passed
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/
    public AdPortalSecurity getIPFRecords(){
        
          //Getting list of job Records ids
         list<Job_Jacket__c> jobList = [SELECT Id ,Integrated_Project_Folder__c FROM Job_Jacket__c where Id =: jobSet or ( Integrated_Project_Folder__c = :recordIdSet  and Integrated_Project_Folder__c != NULL) ];
         map<Id,set<Id>> objectJobIdMap =new map<Id,set<Id>>();
         
         for(Job_Jacket__c job : jobList){
            
             set<Id> tempJobSet=new set<Id>();
             if(objectJobIdMap != NULL && objectJobIdMap.get(job.Integrated_Project_Folder__c)!=NULL){
                
                tempJobSet=objectJobIdMap.get(job.Integrated_Project_Folder__c);
             }
             tempJobSet.add(job.Id);
             objectJobIdMap.put(job.Integrated_Project_Folder__c,tempJobSet);
         }
         if(objectJobIdMap != NULL && objectJobIdMap.size() > 0){
            
             objectNameRecordJobIdMap.put('Integrated_Project_Folder__c',objectJobIdMap);
             
         }
         
         return this;
    }
    
   /*******************************************************************
    Purpose     :  This method will be executed to deliverable records based on records ids passed
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/
    public AdPortalSecurity getDeliverableRecords(){
        
         map<Id,set<Id>> objectJobIdMap =new map<Id,set<Id>>();
         
         list<Job_Jacket_Deliverable__c> jobDeliverableList = [SELECT Deliverable__c , Job_Jacket__c FROM Job_Jacket_Deliverable__c WHERE Job_Jacket__c =:recordIdSet or Deliverable__c=: recordIdSet or Id=:recordIdSet ];
        
         for(Job_Jacket_Deliverable__c jobDeliverable : jobDeliverableList){
            
             set<Id> tempJobSet;
             if(objectJobIdMap != NULL && objectJobIdMap.get(jobDeliverable.Deliverable__c)!=NULL){
                
                tempJobSet=objectJobIdMap.get(jobDeliverable.Deliverable__c);
             }
             else {
                tempJobSet=new set<Id>();
             }
             tempJobSet.add(jobDeliverable.Job_Jacket__c);
             objectJobIdMap.put(jobDeliverable.Deliverable__c,tempJobSet);
             
             jobSet.add(jobDeliverable.Job_Jacket__c);
         }
         
            
         objectNameRecordJobIdMap.put('Job_Asset__c',objectJobIdMap);
             
         
         return this;
    }
    
    
       /*******************************************************************
    Purpose     :  This method will be executed to bid records based on records ids passed
    Parameters  :  
    Returns     : AdPortalSecurity
    ********************************************************************/
    public AdPortalSecurity getBidRecords(){
        
         map<Id,set<Id>> objectJobIdMap =new map<Id,set<Id>>();
         
         list<Bid__c> bidList = [SELECT Id , Job_Jacket_Name__c FROM Bid__c WHERE Job_Jacket_Name__c =:recordIdSet or Id = : recordIdSet];
         
         for(Bid__c bid : bidList){
            
             set<Id> tempJobSet=new set<Id>();
             if(objectJobIdMap != NULL && objectJobIdMap.get(bid.Id)!=NULL){
                
                tempJobSet=objectJobIdMap.get(bid.Id);
             }
             else {
                tempJobSet=new set<Id>();
             }
             tempJobSet.add(bid.Job_Jacket_Name__c);
             objectJobIdMap.put(bid.Id,tempJobSet);
             
              jobSet.add(bid.Job_Jacket_Name__c);
         }
         
         if(objectJobIdMap != NULL && objectJobIdMap.size() > 0){
            
             objectNameRecordJobIdMap.put('Bid__c',objectJobIdMap);
             
         }
         
         return this;
    }
    
    
    public AdPortalSecurity deleteGroups(set<String> grouNames){
        
        
        list<Group> groupList = [Select Id from Group where developername =: grouNames];
        
        Database.delete(groupList,false);
        
        return this;
        
    }
    /*******************************************************************
    Purpose     : this method is used to associate group name and its job ids
    Parameters  :  
    Returns     : void
    ********************************************************************/
    
    //common methods 
    public map<String,Id> getGroupNameJobMap(set<Id> jobSet){
        
        list<Job_Jacket__c> jobList = [ SELECT Group_Edit_DeveloperName__c, Group_Read_DeveloperName__c,Reference_Code__c FROM Job_Jacket__c WHERE Id = : jobSet];
        
        map<String,Id> groupNameJobIdMap = new map<String,Id>();
        
        for(Job_Jacket__c job : jobList){
            
             String groupEditDeveloperName;
             
             if(job.Group_Edit_DeveloperName__c != NULL){
                
                  groupEditDeveloperName=job.Group_Edit_DeveloperName__c;
             }
             else {
                
                  groupEditDeveloperName = JOB_REFERENCECODE_EDIT.replace('REFERENCECODE',job.Reference_Code__c);
             }
                
            String groupReadDeveloperName;
            
            if(job.Group_Read_DeveloperName__c != NULL){
                
                  groupReadDeveloperName=job.Group_Read_DeveloperName__c;
            }
             else {
                    groupReadDeveloperName = JOB_REFERENCECODE_READ.replace('REFERENCECODE', job.Reference_Code__c);
                    
            }
                
            groupNameJobIdMap.put(groupEditDeveloperName,job.Id);
            groupNameJobIdMap.put(groupReadDeveloperName,job.Id);
        }
        return groupNameJobIdMap;
    }
    
        /*******************************************************************
    Purpose     : this method is used to associate group name and its group ids
    Parameters  :  
    Returns     :  map<String,Id>
    ********************************************************************/
    public map<String,Id> getGroupNameGroupIdMap(set<String> groupDeveloperNameSet){
        
        system.debug('# groupDeveloperNameSet' +groupDeveloperNameSet);
        //retrieving list of existing groups
        list<Group> groupList =[ Select Id,DeveloperName from Group where DeveloperName =: groupDeveloperNameSet ] ;
        
        map<String,Id> groupNameIdmap = new map<String,Id>();
        
        for(Group g : groupList ){
            groupNameIdmap.put(g.DeveloperName,g.Id);
        }
        
        return groupNameIdmap;
    }
    
    /*******************************************************************
    Purpose     :  this method is used to associate job ,access level and its group ids
    Parameters  : 
    Returns     : map<Id,map<String,Id>>
    ********************************************************************/
    
    public map<Id,map<String,Id>> getJobAccessGroupMap(map<String,Id> groupNameJobIdMap, map<String,Id> groupNameIdMap){
        
        map<Id,map<String,Id>> jobAccessLevelGroupMap = new map<Id,map<String,Id>>();
        
        for(String groupName : groupNameJobIdMap.keySet()){
            
                map<String,Id> groupIdAccessLevelMap;
                String jobId=groupNameJobIdMap.get(groupName);
                
                if( jobAccessLevelGroupMap != NULL && jobAccessLevelGroupMap.get(jobId) !=NULL){
                    
                    groupIdAccessLevelMap = jobAccessLevelGroupMap.get(jobId);
                    
                }
                else {
                    
                    groupIdAccessLevelMap = new map<String,Id>();
                }
                
                if( groupName.contains(OmnicomConstant.WRITE_ACCESS_LEVEL.toUpperCase()) && ( groupNameIdMap.get(groupName) != NULL )){
                    
                     groupIdAccessLevelMap.put(OmnicomConstant.WRITE_ACCESS_LEVEL,groupNameIdMap.get(groupName));
                     
                }
                else {
                    
                    groupIdAccessLevelMap.put(OmnicomConstant.READ_ACCESS_LEVEL,groupNameIdMap.get(groupName));
                    
                }
                
                if( groupIdAccessLevelMap != NULL && groupIdAccessLevelMap.size() > 0){
                    
                    jobAccessLevelGroupMap.put( jobId ,groupIdAccessLevelMap );
                    
                }
            
        }
        
        return jobAccessLevelGroupMap;
    }
    
    
    
    
      private String quoteKeySet(Set<Id> mapKeySet)
    {
        String newSetStr = '' ;
        for(Id str : mapKeySet)
            newSetStr += '\'' + str + '\',';

        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
 
     
        return newSetStr;

    }
      private String quoteKeySet(List<Id> mapKeySet)
    {
        String newSetStr = '' ;
        for(Id str : mapKeySet)
            newSetStr += '\'' + str + '\',';

        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
 
        return newSetStr;

    }
    
   
    
}
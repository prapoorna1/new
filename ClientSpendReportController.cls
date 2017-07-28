public with sharing class ClientSpendReportController {
    public String jobName{get;set;}
    public String clientName{get;set;} 
    public Double grandTotal{get;set;}
    public List<Bid__c> jobComponentList{get;set;}
    public List<ClientSpendReportWrapper> clientSpendings{get;set;}    
   
    public ClientSpendReportController (){
        grandTotal = 0.00;
        fetchReportValues();
    }
        
    private void fetchReportValues(){
                  
       List<Job_Jacket__c> clientJobs = [SELECT Name,Job_Jacket_Name__c, External_Job_Jacket_Description__c, Client_Reporting_Entity__r.Name, Total_Amount__c, ( SELECT Product__r.Name FROM Job_Brand_Products__r ) FROM Job_Jacket__c WHERE Job_Open_Date__c = THIS_YEAR AND Client_Reporting_Entity__c = :ApexPages.currentPage().getParameters().get('id') ORDER BY Client_Reporting_Entity__c ]; 
       //system.debug('+++total Cost+++'+clientJobs[0].Total_Amount__c);
       if( clientJobs != NULL && !clientJobs.isEmpty() ){
            clientSpendings = new List<ClientSpendReportWrapper>();
            Job_Jacket__c job = clientJobs[0];
            Double totalCost = 0.0;
            
           
          for(  Job_Jacket__c costRec : clientJobs ){
                String jobProducts = '';
                ClientSpendReportWrapper reportWrapper = new ClientSpendReportWrapper();
                /* if( job.Client_Reporting_Entity__r.Name != costRec.Client_Reporting_Entity__r.Name ){
                     ClientSpendReportWrapper wrapperTemp = new ClientSpendReportWrapper();               
                     job = new Job_Jacket__c();
                     wrapperTemp .products = 'Total';
                    // if(job.Total_Amount__c != null)
                     job.Total_Amount__c =totalCost ;// costRec.Total_Amount__c ;
                    // else
                     //job.Total_Amount__c= 0;
                     wrapperTemp.job = job;
                     clientSpendings.add( wrapperTemp );
                     totalCost =0.0;
                }  */
                         
               for( Job_Brand_Product__c jobProd: costRec.Job_Brand_Products__r ){
                    jobProducts += jobProd.Product__r.Name +',';
                   // if(jobProducts.length()==1)
                    //jobProducts += jobProd.Product__r.Name;
                }
               jobProducts =jobProducts .removeEnd(',');
               // jobProducts = jobProducts.substring(0, jobProducts.length()>0?jobProducts.length():1 - 1 );
                
                reportWrapper.job = costRec;     
                reportWrapper.products = jobProducts;        
               
                clientSpendings.add( reportWrapper );
                totalCost += (costRec.Total_Amount__c > 0 ? costRec.Total_Amount__c : 0.0) ;
                grandTotal += (costRec.Total_Amount__c > 0 ? costRec.Total_Amount__c : 0.0) ;
                job = costRec;
            }

        }        
        
     }
    private class ClientSpendReportWrapper{
        public Job_Jacket__c job{get;set;}
        public String products{get;set;}      
    }      
}
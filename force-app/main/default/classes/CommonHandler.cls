/*
    Project Relationship 
    Total Projects -> COUNT() Project Relationship 
    TotalofProjectsAwarded__c -> 
    
    TEST Class :- CopyProjectRelationshipsTest

*/

public class CommonHandler {
    
    // called from ProjectRelationshipsTrigger 
    public static void ProcessAccount(Set<Id> afterUpdate){
        
        Set<String> uniquecheck = new Set<String>();
        List<ProjectMetricsCalcType__c> prmc = [Select id,name,type__c from ProjectMetricsCalcType__c];
        Map<String,String> prmcMap = new Map<String,String>();
        for(ProjectMetricsCalcType__c ps :prmc){
            prmcMap.put(ps.name,ps.type__c);
        }
        Map<Id,Account> AccountCount = new Map<Id,Account>();
        
        for(Id setId : afterUpdate){
            AccountCount.put(setId,new Account(Id= setId,AwardedNumber__c = 0, TotalofProjectsAwarded__c = 0, Total_Projects__c  = 0, AwardedAmount__c = 0, SpecAmount__c= 0, Specd__c = 0));
        }
        
        for(Project_Relationships__c pr : [select Type__c,id,Project__c,Account__c,Status__c,Project__r.Status__c,Project__r.Project_Potential__c,Project__r.HasBasisofDesign__c from Project_Relationships__c where Account__c IN :AccountCount.keyset() and Project__c != null ]){
            string s = String.valueOf(pr.Account__c) + String.valueOf(pr.Project__c);
            Account acc = AccountCount.get(pr.Account__c);
            
            if(!uniquecheck.contains(s))
                acc.Total_Projects__c += 1;
            
            if(pr.Status__c == 'Awarded' && pr.Project__r.Status__c == 'Closed - Won' && !uniquecheck.contains(s) )
                acc.TotalofProjectsAwarded__c += 1; 
                
            if(pr.Status__c == 'Awarded' && pr.Project__r.Status__c == 'Closed - Won' && !uniquecheck.contains(s) && (prmcMap.get('Awarded').contains(pr.Type__c))  )
                acc.AwardedNumber__c += 1; 
            
            if(pr.Status__c == 'Awarded'  && pr.Project__r.Status__c == 'Closed - Won' && pr.Project__r.Project_Potential__c != null && !uniquecheck.contains(s) && (prmcMap.get('Awarded').contains(pr.Type__c)) ){
                acc.AwardedAmount__c += pr.Project__r.Project_Potential__c;
            }
            
            if(pr.Status__c == 'Awarded' && prmcMap.get('Spec').contains(pr.Type__c) && !uniquecheck.contains(s)){
                acc.Specd__c += 1;
            }
            
            if(pr.Status__c == 'Awarded'  && prmcMap.get('Spec').contains(pr.Type__c) && !uniquecheck.contains(s) && pr.Project__r.Project_Potential__c != null ){
                acc.SpecAmount__c += pr.Project__r.Project_Potential__c ;
            }
            
            uniquecheck.add(s);
        }
        
       if(AccountCount.values().size() > 0)
            update AccountCount.values();
    }
    
    // Called from UpdateParentSalesPotential
     public static void ProcessProject(Set<Id> ProjectIds){
         
         Set<Id> accIds = new Set<Id>();
         for(Project_Relationships__c pr : [select Account__c from Project_Relationships__c where Account__c != null and Project__c IN : ProjectIds ]){
             accIds.add(pr.Account__c);
         }
         if(accIds.size() > 0){
             ProcessAccount(accIds);
         }
     }   
}
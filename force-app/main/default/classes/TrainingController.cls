public with sharing class TrainingController {
  
    @AuraEnabled
    public static Map<String,List<Training__c>> getTrainingController () {
        Map<String,List<Training__c>> mapGrpTOObj = new Map<String,List<Training__c>>();
        for (Training__c obj : [select ID,Name__c,Link__c,RecordType.Name from Training__c ORDER BY Sort_Order__c ASC ]) {
            List<Training__c> lst = new List<Training__c>();
            lst.add(obj);
            if(mapGrpTOObj.containsKey(obj.RecordType.Name)) {
                mapGrpTOObj.get(obj.RecordType.Name).add(obj);
            }else {
                mapGrpTOObj.put(obj.RecordType.Name,lst);
            }
        }
        return mapGrpTOObj;
    }
    
    
    public  List<Training__c> getListTraining(){
        return [select ID,Name__c,Link__c from Training__c ORDER BY Sort_Order__c ASC ];
    }
}
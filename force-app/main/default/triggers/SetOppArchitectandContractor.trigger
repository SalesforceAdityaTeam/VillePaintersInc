trigger SetOppArchitectandContractor on Project_Relationships__c (after insert, after update, after delete)
{
    List<Project__c> opps = new List<Project__c>();
    Set<String> oppIds = new Set<String>();
    
    if(Trigger.isInsert || Trigger.isUpdate)
    {
        Set<Id> accountId = new Set<Id>();
        for(Project_Relationships__c pRelation : Trigger.new)
        {
            accountId.add(pRelation.Account__c);
            if(String.IsNotEmpty(pRelation.Project__c) && String.IsNotEmpty(pRelation.Account__c))
            {
                if(pRelation.Type__c == 'Architect' || pRelation.Type__c == 'General Contractor')
                {
                    oppIds.add(pRelation.Project__c);
                }
            }
        }
        CommonHandler.ProcessAccount(accountId);
    }
    if(Trigger.isDelete || Trigger.isUpdate)
    {
        for(Project_Relationships__c pRelation : Trigger.old)
        {
            if(String.IsNotEmpty(pRelation.Project__c) && String.IsNotEmpty(pRelation.Account__c))
            {
                if(pRelation.Type__c == 'Architect' || pRelation.Type__c == 'General Contractor')
                {
                    oppIds.add(pRelation.Project__c);
                }
            }
        }
    }
    
    for(Project__c customOpp : [select Id, Architect__c, General_Contractor__c, (select Id, Type__c, Account__r.Name from Project_Relationships__r where Account__c != null) from Project__c where Id in :oppIds])
    {
        Boolean hasArchitect = false;
        Boolean hasContractor = false;
        for(Project_Relationships__c pRelation : customOpp.Project_Relationships__r)
        {
            if(pRelation.Type__c == 'Architect')
            {
                customOpp.Architect__c = pRelation.Account__r.Name;
                hasArchitect = true;
            }
            else if(pRelation.Type__c == 'General Contractor')
            {
                customOpp.General_Contractor__c= pRelation.Account__r.Name;
                hasContractor = true;
            }
            if(hasArchitect && hasContractor)
            {
                break;
            }
        }
        opps.add(customOpp);
    }
    
    try
    {
        if(!opps.isEmpty())
        {
            update opps;
        }
    }
    catch(Exception ex)
    {
        system.debug('ex:'+ex);
    }
}
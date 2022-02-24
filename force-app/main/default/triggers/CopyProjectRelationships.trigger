trigger CopyProjectRelationships on Project__c (after insert, after update)
{
    Map<String, String> dealId2ParentOppId = new Map<String, String>();
    for(Project__c deal : Trigger.new)
    {
        if(Trigger.isInsert)
        {
            if(deal.Parent_Project__c != null)
            {
                dealId2ParentOppId.put(deal.Id, deal.Parent_Project__c);
            }
        }
        else
        {
            Project__c oldDeal = Trigger.oldMap.get(deal.Id);
            if(deal.Parent_Project__c != null && deal.Parent_Project__c != oldDeal.Parent_Project__c)
            {
                dealId2ParentOppId.put(deal.Id, deal.Parent_Project__c);
            }
        }
    }
    Map<String, List<Project_Relationships__c>> parentOppId2Realtionships = new Map<String, List<Project_Relationships__c>>();
    for(Project__c parentOpp : [select Id, (select Project__c, Account__c, Comments__c, Contact__c, Status__c, Sub_Type__c, Type__c from Project_Relationships__r) from Project__c where Id in : dealId2ParentOppId.values()])
    {
        if(parentOpp.Project_Relationships__r.size() > 0)
        {
            parentOppId2Realtionships.put(parentOpp.Id, parentOpp.Project_Relationships__r);
        }
        else
        {
            parentOppId2Realtionships.put(parentOpp.Id, new List<Project_Relationships__c>());
        }
    }
    List<Project_Relationships__c> newObjects = new List<Project_Relationships__c>();
    for(ID dealId : dealId2ParentOppId.keySet())
    {
        String parentId = dealId2ParentOppId.get(dealId);
        for(Project_Relationships__c obj : parentOppId2Realtionships.get(parentId))
        {
            Project_Relationships__c newObj = new Project_Relationships__c();
            newObj.Account__c = obj.Account__c;
            newObj.Comments__c = obj.Comments__c;
            newObj.Contact__c = obj.Contact__c;
            newObj.Status__c = obj.Status__c;
            newObj.Sub_Type__c = obj.Sub_Type__c;
            newObj.Type__c = obj.Type__c;
            newObj.Project__c = dealId;
            newObjects.add(newObj);
        }
    }
    if(newObjects.size() > 0)
    {
        insert newObjects;
    }
}
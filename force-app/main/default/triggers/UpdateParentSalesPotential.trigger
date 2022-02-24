trigger UpdateParentSalesPotential on Project__c (after insert, after update, after delete)
{
    Set<String> parentOppIds = new Set<String>();
    if(Trigger.isDelete)
    {
        for(Project__c deleteObj : Trigger.old)
        {
            Project__c oldObj = Trigger.oldMap.get(deleteObj.Id);
            if(oldObj.Parent_Project__c != null && Integer.valueOf(oldObj.Project_Potential__c) != 0)
            {
                parentOppIds.add(oldObj.Parent_Project__c);
            }
        }
    }
    else if(Trigger.isInsert)
    {
        for(Project__c newObj : Trigger.new)
        {
            if(newObj.Parent_Project__c != null && Integer.valueOf(newObj.Project_Potential__c) != 0)
            {
                parentOppIds.add(newObj.Parent_Project__c);
            }
        }
    }
    else
    {
        for(Project__c updateObj : Trigger.new)
        {
            Project__c oldObj = Trigger.oldMap.get(updateObj.Id);
            if(oldObj.Project_Potential__c != updateObj.Project_Potential__c)
            {
                parentOppIds.add(updateObj.Parent_Project__c);
            }
            
            if(oldObj.Parent_Project__c != updateObj.Parent_Project__c)
            {
                if(oldObj.Parent_Project__c != null)
                {
                    parentOppIds.add(oldObj.Parent_Project__c);
                }
                if(updateObj.Parent_Project__c != null)
                {
                    parentOppIds.add(updateObj.Parent_Project__c);
                }
            }
        }
    }
    List<Project__c> updateParentObjs = new List<Project__c>();
    for(Project__c parentObj : [select Name, Project_Potential__c, (select Id, Project_Potential__c from Projects__r) from Project__c where Id in :parentOppIds and Parent__c = 'Parent'])
    {
        Decimal salsPotential = 0;
        for(Project__c childObj : parentObj.Projects__r)
        {
            salsPotential += childObj.Project_Potential__c;
        }
        parentObj.Project_Potential__c = salsPotential;
        updateParentObjs.add(parentObj);
    }
    if(updateParentObjs.size() > 0)
    {
        update updateParentObjs;
    }
}
@isTest
public class TestDataFactory
{
    public static testmethod void createProjectTestRecords()
    {
        Account acc = new Account(Name='testAccount');
        insert acc;
        Contact contact = new Contact(LastName='testContact');
        insert contact;
        
        Project__c testProject1 = new Project__c(Name = 'testPro1');
        insert testProject1;
        
        Project_Relationships__c testProjectRelationship1 = new Project_Relationships__c(Account__c=acc.Id, Project__c=testProject1.Id, Contact__c=contact.Id, Comments__c ='testProject1 Target', Type__c='Architect');
        insert testProjectRelationship1;
        
        Project__c testProject2 = new Project__c(Name = 'testPro2', Parent_Project__c = testProject1.Id, Project_Potential__c = 122);
        insert testProject2;
        Project__c testProject3 = new Project__c(Name = 'testPro3', Parent_Project__c = testProject2.Id, Project_Potential__c = 122);
        insert testProject3;
        Project__c testProject4 = new Project__c(Name = 'testPro4', Parent_Project__c = testProject3.Id, Project_Potential__c = 122);
        insert testProject4;
        
        System.assertEquals(4,[select Id from Project_Relationships__c].size());
        System.assertEquals(122,[select Id, Project_Potential__c from Project__c where Parent__c='Parent'].Project_Potential__c);
        
        testProject4.Parent_Project__c = testProject3.Id;
        update testProject4;
        
        System.assertEquals(4,[select Id from Project_Relationships__c].size());
        testProject3.Parent_Project__c = testProject4.Id;
        update testProject3; 
        System.assertEquals(5,[select Id from Project_Relationships__c].size()); 
        delete testProject2;
        System.assertEquals(4,[select Id from Project_Relationships__c].size());
        
    }
    
    public static testmethod void createProjectRelationshopRecords()
    {
        Account acc = new Account(Name='testAccount');
        insert acc;
        Contact contact = new Contact(LastName='testContact');
        insert contact;
        Project__c testProject1 = new Project__c(Name = 'testPro1');
        insert testProject1;
        Project__c testProject2 = new Project__c(Name = 'testPro2', Parent_Project__c = testProject1.Id, Project_Potential__c = 122);
        insert testProject2;
        Project__c testProject3 = new Project__c(Name = 'testPro3', Parent_Project__c = testProject2.Id, Project_Potential__c = 122);
        insert testProject3;
        Project__c testProject4 = new Project__c(Name = 'testPro4', Parent_Project__c = testProject3.Id, Project_Potential__c = 122);
        insert testProject4;
        
        Project_Relationships__c testProjectRelationship1 = new Project_Relationships__c(Account__c=acc.Id, Project__c=testProject1.Id, Contact__c=contact.Id, Comments__c ='testProject1 Target', Type__c='Architect');
        Project_Relationships__c testProjectRelationship2 = new Project_Relationships__c(Account__c=acc.Id, Project__c=testProject1.Id, Contact__c=contact.Id, Comments__c ='testProject2 core', Type__c='Architect');
        Project_Relationships__c testProjectRelationship3 = new Project_Relationships__c(Account__c=acc.Id, Project__c=testProject1.Id, Contact__c=contact.Id, Comments__c ='testProject3 Target', Type__c='Architect');
        
        
        insert new Project_Relationships__c[] {testProjectRelationship1, testProjectRelationship2, testProjectRelationship3};
        System.assertEquals('testAccount',[select Id, Architect__c, (select Id from Project_Relationships__r)from Project__c].get(0).Architect__c);
        
        Project_Relationships__c testProjectRelationship4 = new Project_Relationships__c(Account__c=acc.Id, Project__c=testProject1.Id, Contact__c=contact.Id, Comments__c ='testProject1 Target', Type__c='General Contractor');
        Project_Relationships__c testProjectRelationship5 = new Project_Relationships__c(Account__c=acc.Id, Project__c=testProject1.Id, Contact__c=contact.Id, Comments__c ='testProject2 core', Type__c='General Contractor');
        Project_Relationships__c testProjectRelationship6 = new Project_Relationships__c(Account__c=acc.Id, Project__c=testProject1.Id, Contact__c=contact.Id, Comments__c ='testProject3 Target', Type__c='General Contractor');
        insert new Project_Relationships__c[] {testProjectRelationship4, testProjectRelationship5, testProjectRelationship6};
        System.assertEquals('testAccount',[select Id, Architect__c, (select Id from Project_Relationships__r)from Project__c].get(0).Architect__c);
        
        CommonHandler.ProcessProject(new set<Id>{testProject1.Id});
        
        update new Project_Relationships__c[]{testProjectRelationship1,testProjectRelationship2};
        delete new Project_Relationships__c[]{testProjectRelationship1,testProjectRelationship2};
        
        
    }
}
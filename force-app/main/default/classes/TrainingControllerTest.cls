@IsTest
public Class TrainingControllerTest{

    public static TestMethod void test(){
        
        Training__c obj = new Training__c();
        obj.Link__c = 'www.google.com';
        obj.Name__c = 'Name';
        obj.Sort_Order__c = 2;
        obj.Group__c = 'Group1';
        insert obj;
        
        Training__c obj1 = new Training__c();
        obj1.Link__c = 'www.google.com';
        obj1.Name__c = 'Name';
        obj1.Sort_Order__c = 2;
        obj1.Group__c = 'Group1';
        insert obj1;
        TrainingController.getTrainingController();
        TrainingController ctrl = new TrainingController ();
        ctrl.getListTraining();
    
    }
}
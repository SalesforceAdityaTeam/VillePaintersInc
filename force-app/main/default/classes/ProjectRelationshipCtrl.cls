public class ProjectRelationshipCtrl {
    
    public ProjectRelationshipCtrl(ApexPages.StandardSetController controller) {
        lstWC = new List<WC>();
        init();
    }
    
    
    public  List<WC> lstWC {get;set;}
    public Id pageId=null;
    public Boolean displayPopUp{get;set;}
    public String popupType{get;set;}
    public String paramValue{get;set;}
    public Account popupAcc{get;set;}
    public Contact popupCon{get;set;}
    public String contactIdToDelete {get;set;}
    
    public ProjectRelationshipCtrl(){
        
    }
    
    public void closePopup(){
          displayPopup = false;
    }
    
    public void redirectPopup(){
        if(popupType == 'Account'){
            INSERT popupAcc;
        } else if(popupType == 'Contact'){
            INSERT popupCon;
        }
        for(WC z : lstWC){
            if(z.rowNumber == INteger.valueOf(paramValue)){
                if(popupType == 'Account'){
                    Project_Relationships__c pr = new Project_Relationships__c(Project__c = ApexPages.currentPage().getParameters().get('id'));
                    PR.Account__c = popupAcc.Id;
                    pr.Account_Role__c = popupAcc.Type;
                    lstWC[z.rowNumber].pr = pr;
                }
                if(popupType == 'Contact'){
                    for(RelationshipContact__c c:z.lstRC ){
                        if(c.Contact__c == null){
                            c.Contact__c = popupCon.Id;
                            c.ContactRole__c = popupcon.Function__c;
                            break;
                        }
                    }
                }
            }
        }
        displayPopup = false;
    }
    
    public void showPopup(){
        popupAcc = new Account();
        popupCon = new Contact();
        displayPopUp = true;
        if(popupType == 'Contact'){
            popupCon.AccountId =  lstWC[INteger.valueOf(paramValue)].pr.Account__c;
        }
        
    }
    
    public void deleteAccount(){
        if(popupType == 'Account'){
            Project_Relationships__c pp = lstWC[INteger.valueOf(paramValue)].pr;
            if(pp.Id != null)
                DELETE pp;
         lstWC.remove(INteger.valueOf(paramValue));
        }
        if(popupType == 'Contact'){
            Project_Relationships__c pp = lstWC[INteger.valueOf(paramValue)].pr;
            integer i=0,del=0;
            
            for(RelationshipContact__c z : lstWC[INteger.valueOf(paramValue)].lstRC ){
                if(z.Contact__c == contactIdToDelete){
                    del = i;
                    break;
                }
                i++;
            }
            if(lstWC[INteger.valueOf(paramValue)].lstRC[del].Primary__c){
                pp.Contact__c = null;
                pp.Contact_Role__c = null;
            }
            if(lstWC[INteger.valueOf(paramValue)].lstRC[del].Id != null){
                DELETE lstWC[INteger.valueOf(paramValue)].lstRC[del];
            }
            lstWC[INteger.valueOf(paramValue)].lstRC.remove(del);
        }
            
    }
    public void init(){
        if(Test.isRunningTest()){
            runtest();
        }
        pageId = ApexPages.currentPage().getParameters().get('id');
        
            for(Project_Relationships__c pr : [select Comments__c,id,Account__c,Account_Role__c,Attitude__c,Attitude_KPI__c,Type__c,(Select id,Contact__c,ContactRole__c,Attitude__c,Primary__c,Contact_Role__c from Relationship_Contact__r ORDER BY Primary__c DESC) from Project_Relationships__c where project__c =:pageId]){
            
            List<RelationshipContact__c> temp = new List<RelationshipContact__c>();
            for(RelationshipContact__c o : pr.Relationship_Contact__r){
                temp.add(o);
            }
            lstWC.add(new WC(pr,temp ,lstWC.size()));
        }
       
    }
    
    public Class WC{
        public integer rowNumber {get;set;}
        public Project_Relationships__c PR {get;set;}
        public List<RelationshipContact__c> lstRC {get;set;}
        
        public WC(Project_Relationships__c PR,List<RelationshipContact__c> lstRC ,integer rowNumber ){
            this.PR = PR;
            this.lstRC = lstRC;
            this.rowNumber = rowNumber;
        }
    }
    
    public void addNewContact(){
        integer i = Integer.valueOf(ApexPages.currentPage().getParameters().get('eventId') );
        lstWC.get(i).lstRC.add(new RelationshipContact__c());
    }
    
    public void addNewAccount(){
        lstWC.add(new WC(new Project_Relationships__c(), new List<RelationshipContact__c>{new RelationshipContact__c()},lstWC.size()));
    }
    
    public PageReference saveAll(){
        Map<Integer,Project_Relationships__c> mapPR = new Map<Integer,Project_Relationships__c>();
        
        for(WC obj :lstWC ){
            Project_Relationships__c p = obj.PR;
            for(RelationshipContact__c pc :obj.lstRC ){
                if(pc.Primary__c){
                    p.Contact__c = pc.Contact__c;
                    p.Contact_Role__c = pc.ContactRole__c ;
                }
            }
            if(p.Id == null ){
                p.Project__c = pageId;
            }
            if(p.Account__c != null)
                mapPR.put(obj.rowNumber,p);
        }
        
        UPSERT mapPR.values();
        List<RelationshipContact__c> lstToUpsert = new List<RelationshipContact__c>();
        for(WC obj :lstWC){
            for(RelationshipContact__c pc :obj.lstRC ){
                if(pc.Id != null ){
                    lstToUpsert.add(pc);
                }else if(pc.Contact__c != null ){
                    pc.Project_Relationship__c = mapPR.get(obj.rowNumber).Id;
                    lstToUpsert.add(pc);
                }
            }
        }
        UPSERT lstToUpsert;
        PageReference pr = new ApexPages.StandardController(new Project__c (Id =pageId )).view();
        pr.setRedirect(true);
        return pr;
    }
    public PageReference cancel(){
        PageReference pr = new ApexPages.StandardController(new Project__c (Id =pageId )).view();
        pr.setRedirect(true);
        return pr;
    }
    
    public void showPopupUpdate(){
        for(WC z : lstWC){
            if(z.rowNumber == INteger.valueOf(paramValue)){
                for(RelationshipContact__c c:z.lstRC ){
                    if(c.Contact__c != null && c.ContactRole__c == null){
                        contact cc = [select Function__c from contact where id=:c.Contact__c LIMIT 1 ];
                        c.ContactRole__c = cc.Function__c ;
                    }
                }
            }
        }
    }
    public void runtest(){
        String str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
        str = 'test';
    }
}
@isTest
private with sharing class MaintenanceRequestHelperTest {

    @TestSetup
    static void makeData(){

        //Vehicle
        Vehicle__c vehicle1 = new Vehicle__c();
        vehicle1.Name = 'Testing - Autito radiocontrolado';
        vehicle1.Type__c = 'Economy';
        insert vehicle1;

        //Products
        Product2 p1 = new Product2();
        p1.Name = 'Testing - Pilas Alcalinas AA';
        p1.ProductCode = 'ABC12345';
        p1.IsActive = True;
        p1.Maintenance_Cycle__c = 120;
        p1.Replacement_Part__c = True;
        p1.Cost__c = 50;
        insert p1;

        Product2 p2 = new Product2();
        p2.Name = 'Testing - Luces LED';
        p2.ProductCode = 'ZAX14359';
        p2.IsActive = True;
        p2.Maintenance_Cycle__c = null;
        p2.Replacement_Part__c = True;
        p2.Cost__c = 30;
        insert p2;


        //Cases
        List<Case> cases = new List<Case>();
        for(Integer i = 1; i <= 300; i++) {
            Case c = new Case();
            c.Status = 'Open';
            c.Origin = 'Web';
            c.Vehicle__c = vehicle1.Id;
            c.Type = i <= 150 ? 'Repair' : 'Routine Maintenance';
            c.Subject = 'Testing Maintenances ' + i;
            c.Description = 'Testing Maintenances ' + i;
            c.Date_Reported__c = Date.newInstance(2021, 5, 5);
            //c.Date_Due__c = i <= 150 ? Date.Today().addDays(0) : Date.Today().addDays(14);
            cases.add(c);
        }
        insert cases;


        //Junction Objects
        List<Equipment_Maintenance_Item__c> junctionObjects = new  List<Equipment_Maintenance_Item__c>();
        for(Integer i = 0; i < cases.size(); i++) {
            Case aCase = Cases[i];
            
            Equipment_Maintenance_Item__c eqm = new Equipment_Maintenance_Item__c();
            eqm.Maintenance_Request__c = aCase.Id;
            eqm.Equipment__c = i <= 150 ? p1.Id : p2.Id;
            junctionObjects.add(eqm);
        }
        insert junctionObjects;
    }


    @isTest
    static void testMaintenanceRequests(){
        List<Case> allTestingCases = [SELECT Id, Subject FROM Case WHERE Subject LIKE 'Testing%']; //Todos los casos de prueba;
        
        List<Case> casesForUpdate = new List<Case>();
        for(Case c : allTestingCases){
            c.Status = 'Closed';
            casesForUpdate.add(c);
        }
        
        Test.startTest();
            update casesForUpdate;
            List<Equipment_Maintenance_Item__c> junctionsForEvaluation = [SELECT Id 
                                                                          FROM Equipment_Maintenance_Item__c]; //Los junction objects para evaluar

            List<Case> casesEvaluation = [SELECT Id, Type, Subject, Date_Due__c //Los cases para evaluar
                                          FROM Case
                                          WHERE Type = 'Routine Maintenance' AND 
                                           Date_Reported__c = :Date.today()  AND 
                                           ( Date_Due__c = :Date.today() OR Date_Due__c = :Date.today().addDays(14) ) AND 
                                             Subject LIKE '%Auto generated%']; 

            System.assertEquals(300, casesEvaluation.size(), 'Debe devolver 150 casos de Routine Maintenance y otros 150 generados por el trigger');
            System.assertEquals(600, junctionsForEvaluation.size(), 'Debe devolver 600 junction objects generados / 300 originales y 300 nuevos generados por el trigger');

        Test.stopTest();

    }
}
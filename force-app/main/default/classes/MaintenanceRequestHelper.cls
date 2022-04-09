public with sharing class MaintenanceRequestHelper {  

    public static void updateWorkOrders(List<Case> casesTrigger) {
    
        Map<Id, Case> maintenanceCasesTrigger = new Map<Id, Case>();  
        Map<Id, Case> newMaintenanceCases = new Map<Id, Case>();

        
            //GUARDAMOS LOS CASES QUE RECIBIMOS DESDE EL TRIGGER
            for (Case cOld : casesTrigger) {
                if ((cOld.Type == 'Repair' || cOld.Type == 'Routine Maintenance') && cOld.IsClosed == true && cOld.Status == 'Closed') {                  
                    maintenanceCasesTrigger.put(cOld.Id, cOld);  
                }
            }

            //GUARDAMOS LOS IDS DE LOS CASES Y LAS LISTAS DE LOS J.O
            Map<Id, List<Equipment_Maintenance_Item__c>> maintenanceCasesMAP = new map<Id, List<Equipment_Maintenance_Item__c>>();

            for( Equipment_Maintenance_Item__c  emi : [SELECT Id, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__r.Id
                                                       FROM Equipment_Maintenance_Item__c 
                                                       WHERE Maintenance_Request__c IN :maintenanceCasesTrigger.keySet() WITH SECURITY_ENFORCED]){
                 //if(maintenanceCasesMAP.containsKey(emi.Maintenance_Request__r.Id)){
                    //  List<Equipment_Maintenance_Item__c> listEquimItem = maintenanceCasesMAP.get(emi.Maintenance_Request__r.Id);
                    //  	listEquimItem.add(emi);
                    // 	maintenanceCasesMAP.put(emi.Maintenance_Request__r.Id, listEquimItem);

                 //}  else {
                     List<Equipment_Maintenance_Item__c> listEquimItem2 = new List<Equipment_Maintenance_Item__c>();
                     listEquimItem2.add(emi);
                     maintenanceCasesMAP.put(emi.Maintenance_Request__r.Id, listEquimItem2);
                 //}                                       
             }
     
            //NOS QUEDAMOS CON EL MENOR DE LOS CICLOS DE PRODUCTS
            Double mRCycles = 99999;
            for( Id key : maintenanceCasesMAP.keySet() ){           
                for(Equipment_Maintenance_Item__c eq : maintenanceCasesMAP.get(key)){

                    if(eq.Equipment__r.Maintenance_Cycle__c == null) {
                        mRCycles = 0;
                    } else if(eq.Equipment__r.Maintenance_Cycle__c < mRCycles){
                        mRCycles = eq.Equipment__r.Maintenance_Cycle__c; 
                    }
                }
            }

            //ACTUALIZAMOS LOS ATRIBUTOS DE LOS CASES QUE GUARDAMOS ANTERIORMENTE
            for(Case cNew : maintenanceCasesTrigger.values()) {
                Case newCase = new Case();
                newCase.Type = 'Routine Maintenance';
                //newCase.Product__c = cNew.Product__c; //El equipment asociado al Maintance Request
                newCase.Vehicle__c = cNew.Vehicle__c; //El vehiculo asociado al Maintance Request
                newCase.AccountId = cNew.AccountId;
                newCase.Reason = 'Auto generated new Routine Maintenance on closure of Maintenance Request: ' + cNew.Reason;
                newCase.Status = 'New';
                newCase.Priority = 'Medium';
                newCase.Subject = cNew.Subject == null ? 'Auto generated maintenance request' : cNew.Subject + ' - Auto generated';
                newCase.Description = 'Auto generated new Routine Maintenance on closure of Maintenance Request: ' + cNew.Id;
                newCase.Date_Reported__c = Date.today();
                newCase.Date_Due__c = Date.Today().addDays( (Integer)mRCycles );
                newCase.Origin = 'Web';
                newMaintenanceCases.put(cNew.Id, newCase);
            }

             //INSERTAMOS LOS VALORES DE LOS CASOS NUEVOS
        // try {   
            if(newMaintenanceCases.size() > 0) {
                insert newMaintenanceCases.values();
            }

            //GENERAMOS UN NUEVO JUNCTION OBJECT
            List<Equipment_Maintenance_Item__c> equipmentListForInsert = new  List<Equipment_Maintenance_Item__c>();
            for( Id key : maintenanceCasesMAP.keySet() ){           
                for(Equipment_Maintenance_Item__c eq : maintenanceCasesMAP.get(key)){

                    Equipment_Maintenance_Item__c newEquipMaintItem = new Equipment_Maintenance_Item__c();
                    newEquipMaintItem.Maintenance_Request__c = newMaintenanceCases.get(key).Id;
                    newEquipMaintItem.Equipment__c = eq.Equipment__c;
                    equipmentListForInsert.add(newEquipMaintItem);

                }
            }             

            //INSERTAMOS LOS JUNCTION OBJECTS ASOCIADOS AL CASE
            if(equipmentListForInsert.size() > 0) {
                insert equipmentListForInsert;
            }

            System.debug('Los maintenanceCasesTrigger: ' + maintenanceCasesTrigger);
            System.debug('Los newMaintenanceCases: ' + newMaintenanceCases);
            System.debug('Los equipmentListForInsert: ' + equipmentListForInsert);

                     
        // } catch (Exception  e) {

        //     System.debug('Ocurrio una excepcion: ' + e.getMessage()); //En caso de una exception, la mostramos por consola

        // }    
    }   
}
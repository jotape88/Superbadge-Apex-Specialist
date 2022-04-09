trigger MaintenanceRequest on Case (after update) {

    System.debug('Entramos en el trigger');

    if(Trigger.isAfter) {
      //  for (Case tr : Trigger.new) {
       //     if ((tr.Type == 'Repair' || tr.Type == 'Routine Maintenance') && tr.IsClosed == true && tr.Status == 'Closed') {                  
                MaintenanceRequestHelper.updateWorkOrders(Trigger.new);           
        //    }
        //}     
    }    
}
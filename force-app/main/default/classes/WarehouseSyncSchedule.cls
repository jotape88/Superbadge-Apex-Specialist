public with sharing class WarehouseSyncSchedule implements Schedulable {

    public void execute(SchedulableContext ctx) {

        WarehouseCalloutService.runEquipmentCalloutSync();
        String sch = '0 0 1 * * ?';

        System.schedule( 'WarehouseSyncScheduleJob', sch,  new WarehouseSyncSchedule() );
        //System.enqueueJob(new WarehouseCalloutService());
        
    }
}
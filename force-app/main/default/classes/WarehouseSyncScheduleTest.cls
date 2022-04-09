@isTest
public with sharing class WarehouseSyncScheduleTest {

    public static String cRONEXP = '0 0 1 * * ?';
    static testmethod void testWareHouseSyncSchedule() {

       Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

       Test.startTest();
            
            String jobId = System.schedule('WarehouseSyncScheduleJobX', cRONEXP, new WarehouseSyncSchedule() );

            //Integer productsSize = [SELECT COUNT() FROM Product2];
            //System.assertEquals(0, productsSize, 'Products size should be 0 before execution');
       Test.stopTest();

       //Integer productsSize2 = [SELECT COUNT() FROM Product2];
       List<CronTrigger> cronoJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'WarehouseSyncScheduleJobX'];
       System.assertEquals(1, cronoJobs.size(), 'Debe haber un CronTrigger con el nombre WarehouseSyncScheduleJobX');

    }
}
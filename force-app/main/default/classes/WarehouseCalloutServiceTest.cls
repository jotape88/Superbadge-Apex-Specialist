@IsTest
private class WarehouseCalloutServiceTest {
    @isTest 
    private static void testGetCallout() {
        Test.setMock( HttpCalloutMock.class, new WarehouseCalloutServiceMock() ); 

        Test.startTest();
            WarehouseCalloutService.runEquipmentCalloutSync();
            System.enqueueJob( new WarehouseCalloutService() ); //Para que se testee el QueueableContext context
        Test.stopTest();
        
        List<Product2> actualValues = [SELECT Id, Warehouse_SKU__c, Current_Inventory__c FROM Product2];

        System.assertEquals(2, actualValues.size(), 'Se esperan 2 records');
        System.assertEquals('55d66226726b611100aaf741', actualValues[0].Warehouse_SKU__c , 'Se espera el SKU: 55d66226726b611100aaf741');
        System.assertEquals(500, actualValues[1].Current_Inventory__c , 'Se espera un record con quantity: 500');
}

}
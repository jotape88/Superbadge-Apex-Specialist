public with sharing class WarehouseCalloutService implements Queueable {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public static void execute(QueueableContext context){
        runEquipmentCalloutSync();
    }  

    @Future(callout=true)
    public static void runEquipmentCalloutSync() {     
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            
            List<Object> equipments = (List<Object>) JSON.deserializeUntyped(response.getBody());
            List<Product2> productsXUpsert = new List<Product2>();

            for(Object obj : equipments) {
                Map<String, Object> eqsMap = (Map<String, Object>)obj;

                Product2 p2 = new Product2();
                p2.Name = (String)eqsMap.get('name');
                p2.Cost__c = (Decimal)eqsMap.get('cost'); 
                p2.ProductCode = (String)eqsMap.get('sku'); //El productCode debe ser el sku para que funcione el upsert
                p2.Warehouse_SKU__c = (String)eqsMap.get('_id');  //El SKU debe ser el _id para que funcione el upsert
                //p2.Replacement_Part__c = True;
                p2.Replacement_Part__c = (Boolean)eqsMap.get('replacement'); //Si bien la letra pide que sean todos true, solo funciona utilizando el value que nos trae la call
                p2.Current_Inventory__c = (Double)eqsMap.get('quantity');
                p2.Maintenance_Cycle__c = (Double)eqsMap.get('maintenanceperiod');
                p2.Lifespan_Months__c = (Double)eqsMap.get('lifespan');

                productsXUpsert.add(p2);
            }

            //try {
                if(productsXUpsert.size() > 0) {
                    upsert productsXUpsert Warehouse_SKU__c;
                }
            // } catch (DmlException e) {
            //     System.debug('Error al upsertear: ' + e);
            // } 

        // } else {
        //     System.debug('Error: ' + response.getStatusCode());
     }
        
    } 
}
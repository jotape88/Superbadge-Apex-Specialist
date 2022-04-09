@isTest
public class WarehouseCalloutServiceMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {

        String body = '[{"_id": "55d66226726b611100aaf741", "replacement": false, "quantity": 5, "name": "Generator 1000 kW", "maintenanceperiod": 365, "lifespan": 120, "cost": 5000, "sku": "100003"},' + 
                       '{"_id": "55d66226726b611100aaf742", "replacement": true, "quantity": 500, "name": "Baterias de auto", "maintenanceperiod": 120, "lifespan": 5, "cost": 4, "sku": "100004"}]';

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(200);
        return response; 

    }
}
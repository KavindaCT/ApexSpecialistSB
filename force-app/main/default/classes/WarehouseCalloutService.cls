public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    // BEGIN - Method for callout to warehouse
    private HttpResponse getEquipmentList(String endPoint) {
        Http http = new Http(); // Creates new HTTP
        HttpRequest request = new HttpRequest(); // Creates new HTTP Request

        request.setEndpoint(endPoint);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        return response;
    }
    // END - Method for callout to warehouse

    public void execute(QueueableContext context) {
        HttpResponse response = getEquipmentList(
            'https://th-superbadge-apex.herokuapp.com/equipment?_ga=2.62718508.1486847959.1652069389-955821112.1649573746&_gac=1.252914171.1649573746.CjwKCAjw3cSSBhBGEiwAVII0Z5fOwLOb8ywjaBZi7T2HH9QtzK1EuGmo0Nbsq3QnNQLzm4OCWqERZBoCO-IQAvD_BwE'
        );

        if(response.getStatusCode() == 200) {
            List<Product2> existingEquipments = new List<Product2>();
            List<Object> equipments = (List<Object>) JSON.deserializeUntyped(response.getBody());

            for(Object eqp : equipments) {
                Map<String, Object> equipment = (Map<String, Object>) eqp;
                Product2 newEquipment = new Product2(
                    Name = (String) equipment.get('name'),
                    Replacement_Part__c = (Boolean) equipment.get('replacement'),
                    Current_Inventory__c = (Integer) equipment.get('quantity'),
                    Maintenance_Cycle__c = (Integer) equipment.get('maintenanceperiod'),
                    Lifespan_Months__c = (Integer) equipment.get('lifespan'),
                    Cost__c = (Integer) equipment.get('cost'),
                    Warehouse_SKU__c = (String) equipment.get('sku')
                );
                existingEquipments.add(newEquipment);
            }
            upsert existingEquipments Warehouse_SKU__c;
        }
    }
}

@isTest
private class WarehouseCalloutServiceTest {
    @isTest static void testGetCallout() {
        // set callout mock
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        WarehouseCalloutService calloutService = new WarehouseCalloutService();
        HttpResponse response = calloutService.getEquipmentList(
            'https://th-superbadge-apex.herokuapp.com/equipment?_ga=2.62718508.1486847959.1652069389-955821112.1649573746&_gac=1.252914171.1649573746.CjwKCAjw3cSSBhBGEiwAVII0Z5fOwLOb8ywjaBZi7T2HH9QtzK1EuGmo0Nbsq3QnNQLzm4OCWqERZBoCO-IQAvD_BwE'
        );

        // Verify that the response received contains fake values
        String expectedValue = '[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"},{"_id":"55d66226726b611100aaf742","replacement":true,"quantity":183,"name":"Cooling Fan","maintenanceperiod":0,"lifespan":0,"cost":300,"sku":"100004"},{"_id":"55d66226726b611100aaf743","replacement":true,"quantity":143,"name":"Fuse 20A","maintenanceperiod":0,"lifespan":0,"cost":22,"sku":"100005"}]';
        String actualValue = response.getBody();

        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest static void testQueueblePart() {
        // set callout mock
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        // Create queueble instance
        WarehouseCalloutService warehouseCallout = new WarehouseCalloutService();

        Test.startTest();
        System.enqueueJob(warehouseCallout);
        Test.stopTest();

        System.assertEquals(3, [SELECT count() FROM Product2]);
    }
}

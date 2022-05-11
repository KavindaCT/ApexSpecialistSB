@isTest
private class MaintenanceRequestHelperTest {
    @TestSetup
    static void createSampleMaintainanceRecords(){
        // BEGIN - Create sample vehicle
        Vehicle__c testVehicle = new Vehicle__c(Name='Test Vehicle');
        insert testVehicle;
        // END - Create sample vehicle

        // BEGIN - Create sample equipment
        List<Product2> testEquipments = new List<Product2>();

        for(Integer i = 0; i < 3; i++) {
            Product2 testEquipment = new Product2(Name='Test Eqp ' + i, Replacement_Part__c = true);
            testEquipments.add(testEquipment);
        }

        insert testEquipments;
        // END - Create sample equipment

        // BEGIN - Create sample maintainance records
        List<Case> testMtRequests = new List<Case>();

        for(Integer i = 0; i < 150; i++) {
            Case newMtRepairRequest = new Case(
                Type = 'Repair',
                Origin = 'Web',
                Status = 'New',
                Vehicle__c = testVehicle.Id,
                Subject = 'Test Maintainance Repair ' + i,
                Date_Reported__c = Date.Today()
            );
            Case newMtRoutineRequest = new Case(
                Type = 'Routine Maintenance',
                Origin = 'Web',
                Status = 'New',
                Vehicle__c = testVehicle.Id,
                Subject = 'Test Maintainance Routine Maintenance ' + i,
                Date_Reported__c = Date.Today()
            );

            testMtRequests.add(newMtRepairRequest);
            testMtRequests.add(newMtRoutineRequest);
        }

        insert testMtRequests;
        // END - Create sample maintainance records

        // BEGIN - Create sample Equipment Maintainance Items records
        List<Equipment_Maintenance_Item__c> eqpMtItems = new List<Equipment_Maintenance_Item__c>();

        for(Case mtRequest : testMtRequests) {
            for(Product2 newEquipment : testEquipments) {
                Equipment_Maintenance_Item__c eqpMtItem = new Equipment_Maintenance_Item__c(
                    Equipment__c = newEquipment.Id,
                    Maintenance_Request__c = mtRequest.Id
                );

                eqpMtItems.add(eqpMtItem);
            }
        }

        insert eqpMtItems;
        // END - Create sample Equipment Maintainance Items records
    }

    @isTest static void testRecordCreationPositive() {
        List<Case> mtRequests = [SELECT Id, Status FROM Case]; // Get all the new maintainance requests
        Integer expectedSize = mtRequests.size();
        System.debug('Expected records size: ' + expectedSize);
        
        for(Case mtRequest : mtRequests) {
            mtRequest.Status = 'Closed';
        }

        update mtRequests; // Closed the maintainance requests

        List<Case> newMtRequests = [
            SELECT Id, Status, Type FROM Case WHERE Type = 'Routine Maintenance' AND ParentId IN :mtRequests
        ];

        System.assertEquals(expectedSize, newMtRequests.size()); // Checks that closed maintainance requests create new requests

        List<Equipment_Maintenance_Item__c> newEqpMtItems = [
            SELECT Equipment__c, Maintenance_Request__c FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :newMtRequests
        ];

        System.assertEquals(expectedSize * 3, newEqpMtItems.size());
    }

    @isTest static void testRecordCreationNegative() {
        List<Case> mtRequests = [
            SELECT Id, Status, Type, Origin, Subject
            FROM Case
        ]; // Get all the new maintainance requests
        
        for(Case mtRequest : mtRequests) {
            mtRequest.Type = 'Other';
            mtRequest.Origin = 'Phone';
            mtRequest.Subject = 'Test';
        }

        update mtRequests;

        List<Case> newMtRequests = [
            SELECT Id, Status, Type FROM Case WHERE Type = 'Routine Maintenance' AND ParentId IN :mtRequests
        ];

        System.assertEquals(0, newMtRequests.size()); // Checks that closed maintainance requests create new requests
    }
}
public with sharing class MaintenanceRequestHelper {
    public static void createNewRequests(List<Case> updatedMtRequests) {
        List<Case> newMtRequests = new List<Case>(); // Case list used to store newly created Maintanance Requests
        List<Id> closedIds = new List<Id>(); // Id list for store filtered closed status request Id's
        Map<Id, Decimal> mtCycles = new Map<Id, Decimal>(); // Map for closed status request Id's and related min maintanance cycles

        // BEGIN - Get the closed status Id's
        for(Case mRequest : updatedMtRequests) {
            if(mRequest.Status == 'Closed') {
                if (mRequest.type == 'Repair' || mRequest.type == 'Routine Maintenance') {
                    closedIds.add(mRequest.Id);
                }
            }
        }
        // END - Get the closed status Id's

        // BEGIN - Get ID Case map of closed maintanance req's
        Map<Id, Case> closedMtRqs = new Map<Id, Case>([
            SELECT Id, Vehicle__c, Subject, Status, Type,
            (SELECT Id, Equipment__c, Quantity__c FROM Equipment_Maintenance_Items__r)
            FROM Case
            WHERE Id IN :closedIds
        ]);
        // END - Get ID Case map of closed maintanance req's

        // BEGIN - Get the minmum maintainance cycles for closed status Id's
        List<AggregateResult> mtItems = [
            SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :closedIds
            GROUP BY Maintenance_Request__c
        ];

        for(AggregateResult mtItem : mtItems) {
            mtCycles.put((Id)mtItem.get('Maintenance_Request__c'), (Decimal)mtItem.get('cycle'));
        }
        // END - Get the minmum maintainance cycles for closed status Id's

        // BEGIN - Create new maintainance requests
        for(Case closedCase : closedMtRqs) {
            Case newCase = new Case(
                Status = 'New',
                Subject = 'Routine Maintenance',
                Type = 'Routine Maintenance',
                Vehicle__c = closedCase.Vecicle__c,
                Date_Reported__c = Date.Today()
            );

            
        }
        // BEGIN - Create new maintainance requests
    }
}

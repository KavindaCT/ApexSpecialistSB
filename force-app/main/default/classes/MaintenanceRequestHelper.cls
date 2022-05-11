public with sharing class MaintenanceRequestHelper {
    public static void createNewRequests(List<Case> nonUpdatedMtRequests) {
        List<Case> newMtRequests = new List<Case>(); // Case list used to store newly created Maintanance Requests
        List<Id> validIds = new List<Id>(); // Id list for store filtered non closed status request Id's before update
        Map<Id, Decimal> mtCycles = new Map<Id, Decimal>(); // Map for closed status request Id's and related min maintanance cycles
        List<Equipment_Maintenance_Item__c> newMtRqItems = new List<Equipment_Maintenance_Item__c>(); // List for store related Maintainance items for new maintainance requests

        // BEGIN - Get the non-closed status Id's before update
        for(Case mRequest : nonUpdatedMtRequests) {
            if(mRequest.Status != 'Closed') {
                if (mRequest.Type == 'Repair' || mRequest.Type == 'Routine Maintenance') {
                    validIds.add(mRequest.Id);
                }
            }
        }
        // END - Get the non-closed status Id's before update

        // BEGIN - Get ID Case map of closed maintanance req's
        Map<Id, Case> closedMtRqs = new Map<Id, Case>([
            SELECT Id, Vehicle__c, Subject, Status, Type, Product__c,
            (SELECT Id, Equipment__c, Quantity__c FROM Equipment_Maintenance_Items__r)
            FROM Case
            WHERE Id IN :validIds AND Status = 'Closed'
        ]);
        // END - Get ID Case map of closed maintanance req's

        // BEGIN - Get the minmum maintainance cycles for closed status Id's
        List<AggregateResult> mtCycle = [
            SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :validIds
            GROUP BY Maintenance_Request__c
        ];

        for(AggregateResult mtItem : mtCycle) {
            mtCycles.put((Id)mtItem.get('Maintenance_Request__c'), (Decimal)mtItem.get('cycle'));
        }
        // END - Get the minmum maintainance cycles for closed status Id's

        // BEGIN - Create new maintainance requests
        for(Id closedCaseId : closedMtRqs.keySet()) {
            Case newCase = new Case(
                Status = 'New',
                Subject = 'Routine Maintenance',
                Type = 'Routine Maintenance',
                Vehicle__c = closedMtRqs.get(closedCaseId).Vehicle__c,
                Date_Reported__c = Date.Today(),
                // Date_Due__c = Date.Today().addDays((mtCycles.get(closedCaseId)).intValue()),
                Date_Due__c = Date.Today().addDays(5),
                ParentId = closedCaseId
            );
            newMtRequests.add(newCase);
        }

        insert newMtRequests;
        // END - Create new maintainance requests

        // BEGIN - Create related Maintanance Req Items for new cases
        for(Case newMtRq : newMtRequests) {
            for(Equipment_Maintenance_Item__c rqItem : closedMtRqs.get(newMtRq.ParentId).Equipment_Maintenance_Items__r) {
                Equipment_Maintenance_Item__c newRqItem = rqItem.clone();
                newRqItem.Maintenance_Request__c = newMtRq.Id;

                newMtRqItems.add(newRqItem);
            }
        }

        insert newMtRqItems;
        // END - Create related Maintanance Req Items for new cases
    }
}
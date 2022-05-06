public with sharing class MaintenanceRequestHelper {
    public static void createNewRequests(List<Case> nonUpdatedMtRequests) {
        List<Case> newMtRequests = new List<Case>(); // Case list used to store newly created Maintanance Requests
        List<Id> validIds = new List<Id>(); // Id list for store filtered non closed status request Id's before update
        Map<Id, Integer> mtCycles = new Map<Id, Integer>(); // Map for closed status request Id's and related min maintanance cycles

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
            SELECT Id, Vehicle__c, Subject, Status, Type,
            (SELECT Id, Equipment__c, Quantity__c FROM Equipment_Maintenance_Items__r)
            FROM Case
            WHERE Id IN :validIds AND Status = 'Closed'
        ]);
        // END - Get ID Case map of closed maintanance req's

        // BEGIN - Get the minmum maintainance cycles for closed status Id's
        List<AggregateResult> mtItems = [
            SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :validIds
            GROUP BY Maintenance_Request__c
        ];

        for(AggregateResult mtItem : mtItems) {
            mtCycles.put((Id)mtItem.get('Maintenance_Request__c'), (Integer)mtItem.get('cycle'));
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
                Date_Due__c = Date.Today().addDays(mtCycles.get(closedCaseId))
            );
            newMtRequests.add(newCase);
        }

        insert newMtRequests;
        // BEGIN - Create new maintainance requests
    }
}

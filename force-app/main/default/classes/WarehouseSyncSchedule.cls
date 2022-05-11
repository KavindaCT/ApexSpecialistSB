public with sharing class WarehouseSyncSchedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
    }
}
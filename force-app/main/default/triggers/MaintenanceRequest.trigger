trigger MaintenanceRequest on Case (after update) {
    MaintenanceRequestHelper.createNewRequests(Trigger.old);
}
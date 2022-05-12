@isTest
private class WarehouseSyncScheduleTest {
    public static String CRON_EXP = '0 0 1 * * ? 2022'; // sec  min  Hours  Day_of_month  Month  Day_of_week  optional_year

    @IsTest
    static void testWarehouseSyncScheduledJob(){
        // set callout mock
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Test.startTest();
        String jobId = System.schedule('WarehouseSyncScheduleJob1', CRON_EXP, new WarehouseSyncSchedule());
        CronTrigger beforeCt = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, beforeCt.TimesTriggered);
        Test.stopTest();
        
        Integer afterCt = [SELECT count() FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, afterCt);
    }
}

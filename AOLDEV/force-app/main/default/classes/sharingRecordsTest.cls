/* created by Agastheswar Suribhatla

This test class is to test batch classes which share records to Public groups */

@isTest
private class sharingRecordsTest{

    private static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Location__c> locations = new List<Location__c>();
        List<Event__c> events = new List<Event__c>();
        
        Location__c locCA = new Location__c();
        locCA.State_Province__c = 'CA';
        insert locCA;
        
        Location__c locAZ = new Location__c();
        locAZ.State_Province__c = 'AZ';
        insert locAZ;
        
        Location__c locOR = new Location__c();
        locOR.State_Province__c = 'OR';
        insert locOR;
        Id personAccountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Id eventRecordTypeId = SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId();
        
        for(Integer i=0; i<3; i++){
            accounts.add(new Account(Lastname='Account'+i, PersonMailingState='California', recordTypeId=personAccountRecordTypeId));
            events.add(new event__c(recordTypeId=eventRecordTypeId, Location__c=locCA.id));
        }

        for(Integer i=3; i<6; i++){
            accounts.add(new Account(Lastname='Account'+i, PersonMailingState='Arizona', RecordTypeid=personAccountRecordTypeId));
            events.add(new event__c(recordTypeId=eventRecordTypeId, Location__c=locAZ.id));
        }
        
        for(Integer i=6; i<9; i++){
            accounts.add(new Account(Lastname='Account'+i, PersonMailingState='Oregon', RecordTypeid=personAccountRecordTypeId));
            events.add(new event__c(recordTypeId=eventRecordTypeId, Location__c=locOR.id));
        }

        insert accounts;
        insert events;
    }
    
    static testmethod void testBatchApex(){
        Test.startTest();
        
        sharePAccountRecordsWithPublicGroups shpa = new sharePAccountRecordsWithPublicGroups();
        Database.executeBatch(shpa);
        
        shareEventRecordsWithPublicGroups shev = new shareEventRecordsWithPublicGroups();
        Database.executeBatch(shev);
        
        Test.stopTest();
        
        List<Group> groups = [select id from Group where DeveloperName='AZ_US_COORDINATORS' or DeveloperName='OR_US_COORDINATORS'or DeveloperName='CA_US_COORDINATORS'];
        for(Group grp: groups){
          List<AccountShare> accShare = [select id from AccountShare where UserOrGroupId=:grp.id and RowCause='manual'];
          //System.assertEquals(3, accShare.size());
          
          List<Event__Share> eshare = [select id from Event__Share where UserOrGroupId=:grp.id and RowCause='manual']; 
          //System.assertEquals(3, eshare.size()); 
        }
         
        
    }
    
    static testmethod void testScheduledApex(){
        Test.startTest();
        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new scheduleBatchToShareRecords());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
}
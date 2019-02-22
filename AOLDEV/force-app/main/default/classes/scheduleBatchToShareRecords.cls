public class scheduleBatchToShareRecords implements Schedulable{
    public void execute(SchedulableContext sc){
        List<ScheduleApex__mdt> scheduleBatchClasses = [select DeveloperName, isExecutable__c from ScheduleApex__mdt];
        
        for(ScheduleApex__mdt scApex: scheduleBatchClasses){
            if(scApex.DeveloperName == 'SchedulePersonAccountBatch' && scApex.isExecutable__c){
                sharePAccountRecordsWithPublicGroups shpa = new sharePAccountRecordsWithPublicGroups();
                Database.executeBatch(shpa);
            
            } else if(scApex.DeveloperName == 'ScheduleEventRecordBatch' && scApex.isExecutable__c){
                shareEventRecordsWithPublicGroups shev = new shareEventRecordsWithPublicGroups();
                Database.executeBatch(shev);
            }
        }
    }
}
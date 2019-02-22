/* created by Agastheswar Suribhatla

This batch class is used to share the Person Account/ Event records with Public groups */

public class shareEventRecordsWithPublicGroups implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('select Id, Location__r.State_Province__c from Event__c');
    }
    
    public void execute(Database.BatchableContext bc, List<Event__c> scope){
        
        List<group> publicGroups = [Select Id,DeveloperName from Group where Type='Regular'];
        List< Event__Share > eventShares = new List< Event__Share >();
        
        for(Event__c event: scope){

            String groupName = event.Location__r.State_Province__c + '_US_COORDINATORS';
            for(group pGroup: publicGroups){
                if(pGroup.DeveloperName == groupName){
                    Event__Share eshare = new Event__Share();
                    eshare.ParentId = event.id;
                    eshare.UserOrGroupId = pGroup.Id;
                    eshare.AccessLevel = 'Edit';
                    eshare.RowCause = Schema.Event__Share.RowCause.Manual;
                    eventShares.add(eshare);
                }
            }
        }
        List<Database.UpsertResult> sr = Database.upsert(eventShares,false);

    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(' Event Share job has finished');
    }
}
trigger AttendeeTrigger on Attendee__c (before update) {
    
 	if(Trigger.isBefore && Trigger.isUpdate){	
        AttendeeTriggerHandler.beforeUpdate( Trigger.newMap, Trigger.oldMap);
    }
}
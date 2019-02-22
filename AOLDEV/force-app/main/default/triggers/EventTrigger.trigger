trigger EventTrigger on Event__c (before insert, before update, after insert, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        EventTriggerHandler.beforeInsert(Trigger.New);
    }
    if(Trigger.isBefore && Trigger.isUpdate){	
        EventTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        EventTriggerHandler.afterInsert(Trigger.New);
    }	
    if(Trigger.isAfter && Trigger.isUpdate){
        EventTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }	
}
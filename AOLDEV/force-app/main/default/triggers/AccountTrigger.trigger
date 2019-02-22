trigger AccountTrigger on Account (before insert, before update, after insert, after update) {

    if(trigger.isBefore && trigger.isInsert){
        System.debug('Account Trigger before Insert ' + trigger.new);
        AccountTriggerHandler.handleBeforeInsert(trigger.new);
    
    }
    else if (trigger.isBefore && trigger.isUpdate){
        AccountTriggerHandler.handleBeforeUpdate(trigger.oldMap, trigger.newMap);
    }
    else if(trigger.isAfter && trigger.isInsert){
        System.debug('Account Trigger After Insert Map ' + trigger.newMap);
        
        AccountTriggerHandler.handleAfterInsert(trigger.newMap);
    }
    else if (trigger.isAfter && trigger.isUpdate){
        AccountTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.newMap);
    }
}
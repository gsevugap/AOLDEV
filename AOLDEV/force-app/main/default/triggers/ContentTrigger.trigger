trigger ContentTrigger on Content__c (before insert, before update) {
    
  if(Trigger.isBefore && Trigger.isInsert){
	ContentTriggerHandler.beforeInsert(Trigger.New, false);
  }
    
  if(Trigger.isBefore && Trigger.isUpdate){
	ContentTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
  }
}
trigger ContentActivityTrigger on Content_Activity__c (after insert) {
   ContentActivityTriggerHandler.updateContentRollup(Trigger.New);

}
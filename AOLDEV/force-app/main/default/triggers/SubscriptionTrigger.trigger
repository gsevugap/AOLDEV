trigger SubscriptionTrigger on Subscription__c (before update, before insert, after insert, before delete) {
  if(Trigger.isAfter && Trigger.isInsert){
    StripeSubscriptionProductAndPlanHandler.createSubscriptionProductAndPlanInStripe(Trigger.New);
  }
    
  if(Trigger.isBefore && Trigger.isInsert){
    StripeSubscriptionProductAndPlanHandler.beforeInsert(Trigger.New);
  }
    
  if(Trigger.isBefore && Trigger.isUpdate){
    StripeSubscriptionProductAndPlanHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
  }
    
  if(Trigger.isBefore && Trigger.isDelete){
    StripeSubscriptionProductAndPlanHandler.beforeDelete(Trigger.old);
  }
}
trigger PriceRulesAndCouponTrigger on Price_Rules_And_Coupons__c (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
    	PriceRulesAndCouponTriggerHandler.beforeInsertAndUpdate(Trigger.new);    
    }
    if(Trigger.isBefore && Trigger.isUpdate){ 
	 	PriceRulesAndCouponTriggerHandler.beforeInsertAndUpdate(Trigger.new);        
    }

}
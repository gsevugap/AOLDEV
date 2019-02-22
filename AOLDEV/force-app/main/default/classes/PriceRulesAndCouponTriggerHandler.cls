public class PriceRulesAndCouponTriggerHandler {
    
    
    public static void beforeInsertAndUpdate(List<Price_Rules_And_Coupons__c> listOFPriceRuleAndCoupon){
		Id priceRuleRecordTypeId = SObjectType.Price_Rules_And_Coupons__c.getRecordTypeInfosByDeveloperName().get('Price_Rule').getRecordTypeId();       
		Map<String, List<Price_Rules_And_Coupons__c>> mapOfExistingRule = getExistingRuleMapByWorkshopOrCtype();
        for(Price_Rules_And_Coupons__c pr : listOFPriceRuleAndCoupon){
            if(pr.RecordTypeId == priceRuleRecordTypeId){
                Id alreadyExistedRuleId = isRuleAlreadyExist(pr, mapOfExistingRule);
                if(alreadyExistedRuleId != null){
                    pr.addError('Rule already exist, Rule id is : '+alreadyExistedRuleId);
                }   
            }
        }
      
    }
    
    private static Map<String, List<Price_Rules_And_Coupons__c>> getExistingRuleMapByWorkshopOrCtype(){
      List<Price_Rules_And_Coupons__c> listOfExistingRules = [select id, CType_Product_Workshop__c, Workshop__c, City__c, 
         														Country__c, State__c , Zip_Postal_Code__c , Valid_From_Date__c , 
         														Valid_Till_Date__c  from   Price_Rules_And_Coupons__c where Is_Active__c  = true 
                                                                And RecordType.name ='Price Rule'];  
      Map<String, List<Price_Rules_And_Coupons__c>> mapOfExistingRule = new Map<String, List<Price_Rules_And_Coupons__c>>();
        for(Price_Rules_And_Coupons__c pr : listOfExistingRules){
            String field = String.isNotBlank(pr.Workshop__c)? 'Workshop__c' : 'CType_Product_Workshop__c';
            String key = (String)pr.get(field);
            if(!mapOfExistingRule.containsKey(key)){
                List<Price_Rules_And_Coupons__c> listOfRule = new List<Price_Rules_And_Coupons__c>();
				mapOfExistingRule.put(key, listOfRule);                    
            }
            mapOfExistingRule.get(key).add(pr);
        } 
        return mapOfExistingRule;
    }
    
    private static Id isRuleAlreadyExist(Price_Rules_And_Coupons__c pr, Map<String, List<Price_Rules_And_Coupons__c>> mapOfExistingRule){
        String field = String.isNotBlank(pr.Workshop__c)? 'Workshop__c' : 'CType_Product_Workshop__c';
        String key = (String)pr.get(field);
        if(!mapOfExistingRule.containsKey(key)){ 
            return null;
        } else {
            List<Price_Rules_And_Coupons__c> listOfExistingRules = mapOfExistingRule.get(key);
            for(Price_Rules_And_Coupons__c prExisting: listOfExistingRules){
                if(prExisting.id == pr.id){
                    continue;
                }
                if(prExisting.Valid_From_Date__c != null && prExisting.Valid_Till_Date__c !=null){
                    if((pr.Valid_From_Date__c <= prExisting.Valid_Till_Date__c && pr.Valid_From_Date__c >= prExisting.Valid_From_Date__c) || 
                       (pr.Valid_Till_Date__c <= prExisting.Valid_Till_Date__c && pr.Valid_Till_Date__c >= prExisting.Valid_From_Date__c)) {
                           if(checkIfAddressIsSame(pr, prExisting )){
                               return prExisting.id;
                           } 
                       }
                }else {
                if(checkIfAddressIsSame(pr, prExisting )){
                    return prExisting.id;
                } 
            } 
          }
          return null;  
        }
    }
    
    @TestVisible
    private static boolean checkIfAddressIsSame(Price_Rules_And_Coupons__c newPr, Price_Rules_And_Coupons__c existingPr){
        if(
           String.isNotBlank(newPr.Zip_Postal_Code__c) && 
           String.isNotBlank(newPr.City__c) && 
           String.isNotBlank(newPr.State__c) && 
           String.isNotBlank(newPr.Country__c) &&
           newPr.Zip_Postal_Code__c == existingPr.Zip_Postal_Code__c && 
           newPr.City__c == existingPr.City__c && 
           newPr.State__c == existingPr.State__c && 
           newPr.Country__c == existingPr.Country__c 
          ){
            return true;
          } 
        else if(
           String.isBlank(newPr.Zip_Postal_Code__c) && 
           String.isBlank(existingPr.Zip_Postal_Code__c)&&  
           String.isNotBlank(newPr.City__c) && 
           String.isNotBlank(newPr.State__c) && 
           String.isNotBlank(newPr.Country__c) &&
           newPr.City__c == existingPr.City__c && 
           newPr.State__c == existingPr.State__c && 
           newPr.Country__c == existingPr.Country__c 
          ){
            return true;
          }
        else if(
           String.isBlank(newPr.Zip_Postal_Code__c) && 
           String.isBlank(newPr.City__c) && 
           String.isBlank(existingPr.Zip_Postal_Code__c)&& 
           String.isBlank(existingPr.City__c)&&  
           String.isNotBlank(newPr.State__c) && 
           String.isNotBlank(newPr.Country__c) &&
           newPr.State__c == existingPr.State__c && 
           newPr.Country__c == existingPr.Country__c 
          ){
            return true;
          }
        else if(
           String.isBlank(newPr.Zip_Postal_Code__c) && 
           String.isBlank(newPr.City__c) && 
           String.isBlank(newPr.State__c) && 
           String.isBlank(existingPr.Zip_Postal_Code__c)&& 
           String.isBlank(existingPr.City__c)&&
           String.isBlank(existingPr.State__c)&&
           String.isNotBlank(newPr.Country__c) &&  
           newPr.Country__c == existingPr.Country__c 
          ){
            return true;
          } 
        else{
              return false;
          }
    }
}
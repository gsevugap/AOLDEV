public class StripeSubscriptionProductAndPlanHandler extends StripeApi {
	
    
    public static void beforeUpdate(Map<Id,Subscription__c> mapOfNew, Map<Id,Subscription__c> mapOfOld){
        for(String key : mapOfNew.keySet()){
            Subscription__c newSub = mapOfNew.get(key);
			Subscription__c oldSub = mapOfOld.get(key);
            
            if(!(newSub.Interval__c == oldSub.Interval__c &&  
               newSub.Price__c  == oldSub.Price__c  && 
               newSub.Subscription_Master__c  == oldSub.Subscription_Master__c  &&
               newSub.Subscription_Name__c  == oldSub.Subscription_Name__c  &&
               (String.isBlank(oldSub.Subscription_Product__c ) || newSub.Subscription_Product__c  == oldSub.Subscription_Product__c )  &&
               (String.isBlank(oldSub.Stripe_Plan_Id__c ) || newSub.Stripe_Plan_Id__c  == oldSub.Stripe_Plan_Id__c  ) &&
               (String.isBlank(oldSub.Stripe_Product_Id__c ) ||  newSub.Stripe_Product_Id__c  == oldSub.Stripe_Product_Id__c  )
              )) {
                  newSub.addError('Unable to update, This plan is with in sync with Strip. Please create new plan and deactivate this. ');
              }
            
        }
    }
    
    public static void beforeDelete(List<Subscription__c> listOfOld){
        for(Subscription__c sub :listOfOld){
            if( String.isNotBlank(sub.Stripe_Plan_Id__c ) ||  String.isNotBlank(sub.Stripe_Product_Id__c )) {
                  sub.addError('Unable to delete. This plan is with in sync with Stripe. Please mark Inactive instead of delete.');
              }
         }
    }
    
     public static void beforeInsert(List<Subscription__c> listOfNew){
        List<Subscription__c> listOfExistingSubscription = [Select id, Interval__c , Subscription_Master__c from Subscription__c where Is_Active__c = true ];
        Map<String,String> mapOfExistingSubscription = new Map<String,String>();
        for(Subscription__c sub :listOfExistingSubscription){
            String key = sub.Interval__c+sub.Subscription_Master__c;
            mapOfExistingSubscription.put(key, sub.id); 
        }  
                     System.debug('mapOfExistingSubscription -'+mapOfExistingSubscription);
        for(Subscription__c sub :listOfNew){
            String key = sub.Interval__c+sub.Subscription_Master__c;
            System.debug('key -'+key);
            if(mapOfExistingSubscription.containsKey(key)){
                  sub.addError('Unable to add a subscription becuase already created with same interval and type. Please see this record : '+ mapOfExistingSubscription.get(key));
              }
         }
    }
    
    /*Assuming that we will not having much record for this object and all of 
    * them created through UI and one at a time on after insert
	**/
    public static void createSubscriptionProductAndPlanInStripe(List<Subscription__c> listOfNewSubscriptionObject){
        Subscription__c obj = listOfNewSubscriptionObject[0];
        if(String.isBlank(obj.Interval__c) || String.isBlank(obj.Subscription_Name__c) || obj.Price__c == null){
            obj.addError('Please fill interval, name and price');
        } else{
        	System.debug(' This object is craeted '+obj);
        	createSubscriptionProductAndPlanInStripeFuture(obj.id);    
        }
    }
    

    @future(callout = true)
    public static void createSubscriptionProductAndPlanInStripeFuture(String subscriptionId){
        
        System.debug(' This object is craeted id '+subscriptionId);
        System.debug([select id,Is_Active__c,Interval__c, Stripe_Plan_Id__c, Stripe_Product_Id__c, Subscription_Name__c, Price__c  
                                           	from Subscription__c]);
        
        Subscription__c newSubscription = [select id,Is_Active__c,Interval__c, Stripe_Plan_Id__c, Stripe_Product_Id__c, Subscription_Name__c, Price__c  
                                           	from Subscription__c where id =:subscriptionId];
        
        String productName = newSubscription.Subscription_Name__c;
        // first we need to create product in stripe

        HttpRequest httpReq = new HttpRequest();
		httpReq.setEndpoint(getStripeURL()+'/products');
		httpReq.setMethod('POST');
		httpReq.setHeader('Authorization', getStripAuthorizationHeader());
        Map<String, String> payload = new Map<String, String>{
			'name' => productName,
            'type' => 'service'                
		};
        httpReq.setBody(urlify(payload));
        Http http = new Http();
        try{
        	HttpResponse hs = http.send(httpReq);
            if(hs.getStatusCode() != 200){
               //newSubscription.addError('unable to create product on stripe - Please contact to admin'); 
			   System.debug('unable to create product on stripe response '+hs);
            }else {
                Map<String, Object> response = (Map<String,Object>)JSON.deserializeUntyped(hs.getBody());
                newSubscription.Stripe_Product_Id__c = response.get('id').toString();
                // Now we need to create plan in stripe
         		newSubscription = createSubscriptionPlan(newSubscription);
                if(newSubscription != null){
    				
                    //createProduct and price as well
                    Id recordTypeIdForProductAddOn = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
                      .get('Subscription').getRecordTypeId();
                     Product2 pr = new Product2(IsActive  = true, 
                                            name = productName, Product_Subscription_Category__c = 'None', RecordtypeId = recordTypeIdForProductAddOn );
                     insert pr;
                     List<Pricebook2> listOfPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];
                     if(listOfPriceBook.size() > 0 ){ 
            			String priceBookId = listOfPriceBook.get(0).id;    
                     	PricebookEntry pbe = new PricebookEntry(Pricebook2Id  =priceBookId, Product2Id  =pr.id, UnitPrice = newSubscription.Price__c, IsActive = true );
                        insert pbe ;
                     }else{
                         throw new StripeException(' No standard price book available ');
                     } 
                    newSubscription.Subscription_Product__c  = pr.id;
                    update newSubscription;
	                System.debug('Product and plan created sucessfully for -> '+newSubscription.Subscription_Name__c);                
                }
            }
        }catch(StripeException e){
            System.debug('unable to create product on stripe, error log is '+e);
            //newSubscription.addError('unable to create product on stripe - Please contact to admin'); 
        }
       
    } 
    
    public static Subscription__c createSubscriptionPlan(Subscription__c newSubscription){
        String nickName = newSubscription.Interval__c;
        String interval = 'month';
        String intervalCount = '1';
        String price = newSubscription.Price__c.toPlainString();
        price = price.remove('.');
        
        //identify interval_count
        if(nickName == 'Half Yearly'){
            intervalCount = '6';
        } else if(nickName == 'Quarterly') {
            intervalCount = '3';
        }
       
        // set interval
        if(nickName == 'Yearly'){
          	interval = 'year'; 
        } 
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(getStripeURL()+'/plans ');
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', getStripAuthorizationHeader());
        Map<String, String> payload = new Map<String, String>{
            'product' => newSubscription.Stripe_Product_Id__c,
                'currency' => 'usd',
                'interval' => interval,
                'interval_count' => intervalCount,
                'billing_scheme' => 'per_unit',
                'nickname' => nickName,
                'amount' => price    
                
                };
        httpReq.setBody(urlify(payload));
        Http http = new Http();
        try{
        	HttpResponse hs = http.send(httpReq);
            if(hs.getStatusCode() != 200){
               //newSubscription.addError('unable to create plan on stripe - Please contact to admin'); 
               System.debug('unable to create plan on stripe response '+hs);
                return null;
            }else {
                Map<String, Object> response = (Map<String,Object>)JSON.deserializeUntyped(hs.getBody());
               	newSubscription.Stripe_Plan_Id__c = response.get('id').toString();
                return newSubscription;
            }
           
        }catch(StripeException e){
            System.debug('unable to create plan on stripe, error log is '+e);
            //newSubscription.addError('unable to create plan on stripe - Please contact to admin');
            return null;
        }
    }
    
    
}
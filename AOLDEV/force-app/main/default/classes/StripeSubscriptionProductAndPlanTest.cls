@IsTest
public with sharing class StripeSubscriptionProductAndPlanTest {
	
	@testSetup static void setupData() {
		Test.startTest();
     	Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMockImpl());
     	Subscription_Master__c sm = new Subscription_Master__c(
     		name = 'test', 
     		Subscription_Type__c = 'Digital', 
     		Display_order__c = 1, 
     		Precedence_Order__c =2, 
     		Is_Active__c = true 
     	);
     	insert sm;
     	Subscription__c sc = new Subscription__c();
     	sc.Interval__c = 'Monthly';
     	sc.Subscription_Master__c = sm.id;
     	sc.Subscription_Name__c = 'test';
     	sc.Price__c = 40;
     	sc.Is_Active__c = true;
     	insert sc;
     	
     Test.stopTest();
	
    }
	
	@IsTest
     public static void createSubscription() {
     	Test.startTest();
     	Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMockImpl());
        Subscription__c sc = [select id from Subscription__c limit 1];
     	sc.Is_Active__c = false;
     	update sc;
     	try{
     		delete sc;
     	}catch(Exception e){
     		//deleting is not allowed if this is synced with stripe
     		 System.assertEquals('Unable to delete. This plan is with in sync with Stripe. Please mark Inactive instead of delete.', e.getMessage());
     		
     	}
     	 Test.stopTest();
     
    }   
    
    
}
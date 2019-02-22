@isTest
private class GenerateCouponsCtrTest {

	private static testMethod void test() {
        GenerateCouponsCtr ctrl = new GenerateCouponsCtr();
        List<Event__c> events = TestUtility.createWorkshop(true);
        Event__c event = events[0];
        ctrl.Coupon.Valid_From_Date__c = Date.today();  
        ctrl.generateAction();
        System.assert(TestUtility.wasMessageAdded(new ApexPages.Message(ApexPages.severity.WARNING,'Please select either both date or leave them blank.')));
        
        ctrl.Coupon.Valid_From_Date__c = null;
        ctrl.Coupon.Coupon_Type__c = 'Subscription';
        ctrl.Coupon.Discount_Type__c = 'Percentage';
        ctrl.generateAction();
        System.assert(TestUtility.wasMessageAdded(new ApexPages.Message(ApexPages.severity.WARNING,'Please select Discount type = Trial Days because we are not giving any discount on subscription based on money but on trial period.')));
                
        ctrl.Coupon.Coupon_Type__c = 'Workshop';
        ctrl.Coupon.Workshop__c = event.id;
        ctrl.Coupon.Discount_Type__c = 'Trial Days';
        ctrl.generateAction();
        System.assert(TestUtility.wasMessageAdded(new ApexPages.Message(ApexPages.severity.WARNING,'Please select Discount type as percentage or flat price not trial days')));
        
		        
        ctrl.Coupon.Discount_Percentage_OR_Flat_Price_OR_Day__c = 77;
        ctrl.Coupon.Discount_Type__c = 'Percentage';
        ctrl.generateAction();
        //System.assert(TestUtility.wasMessageAdded(new ApexPages.Message(ApexPages.severity.WARNING,'Coupon Discount in percentage should not more than 100 %')));
        
        
        ctrl.Coupon.Coupon_Type__c = '';
        ctrl.generateAction();
        System.assert(TestUtility.wasMessageAdded(new ApexPages.Message(ApexPages.severity.WARNING,'Coupon type is required field.')));
        
        ctrl.NoOfCoupon = 7;
        ctrl.generateAction();
        System.assert(TestUtility.wasMessageAdded(new ApexPages.Message(ApexPages.severity.WARNING,'Please enter required coupons and should be greater than 0.')));

        
         
        ctrl.Coupon.Coupon_Type__c = 'Workshop';
        ctrl.Coupon.Workshop__c = event.id;
        ctrl.Coupon.Discount_Type__c = 'Percentage';
        ctrl.Coupon.Discount_Percentage_OR_Flat_Price_OR_Day__c = 22;
        ctrl.NoOfCoupon = 20;
        ctrl.generateAction();
        
        ctrl.downloadCSVAction();
	}
}
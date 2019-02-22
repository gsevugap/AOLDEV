@isTest
public with sharing class PriceRulesAndCouponTriggerHandlerTest {
    
    @isTest
    
    public static void testCheckIfAddressIsSame(){
       		Price_Rules_And_Coupons__c pc0 = new Price_Rules_And_Coupons__c();
			pc0.Zip_Postal_Code__c = '3040';
			pc0.City__c = 'FREEMONdT';
			pc0.State__c = 'SC';
			pc0.Country__c = 'US';
			pc0.Is_Active__c = true;
			pc0.Workshop_Price__c = 40;
        
        	Price_Rules_And_Coupons__c pc1 = new Price_Rules_And_Coupons__c();
			pc1.Zip_Postal_Code__c = '3040';
			pc1.City__c = 'FREEMONdT';
			pc1.State__c = 'SC';
			pc1.Country__c = 'US';
			pc1.Is_Active__c = true;
			pc1.Workshop_Price__c = 40;
        
        	System.assertEquals(true, PriceRulesAndCouponTriggerHandler.checkIfAddressIsSame(pc0, pc1));
        	pc0.Zip_Postal_Code__c = null;
            pc1.Zip_Postal_Code__c = null;
        System.assertEquals(true, PriceRulesAndCouponTriggerHandler.checkIfAddressIsSame(pc0, pc1));
        	pc0.Zip_Postal_Code__c = null;
        	pc0.City__c = null;
            pc1.Zip_Postal_Code__c = null;
        	pc1.City__c = null;
        System.assertEquals(true, PriceRulesAndCouponTriggerHandler.checkIfAddressIsSame(pc0, pc1));
        	pc0.Zip_Postal_Code__c = null;
        	pc0.City__c = null;
        	pc0.State__c = null;
            pc1.Zip_Postal_Code__c = null;
        	pc1.City__c = null;
        	pc1.State__c = null;
        System.assertEquals(true, PriceRulesAndCouponTriggerHandler.checkIfAddressIsSame(pc0, pc1));
        pc1.State__c = 'MN';
        System.assertEquals(false, PriceRulesAndCouponTriggerHandler.checkIfAddressIsSame(pc0, pc1));
        
        
        
    }
    
    
	@isTest 
	 public static void setupPrices() {
	 	
		 	try{
			List<Price_Rules_And_Coupons__c> listOfPriceCoupon = new List<Price_Rules_And_Coupons__c>();
			String idPriceRuleRecordType = TestUtility.getRecordType('Price_Rule', 'Price_Rules_And_Coupons__c');
			String idCouponRecordType = TestUtility.getRecordType('Coupon', 'Price_Rules_And_Coupons__c');
			List<Event__c> listOfEvent = TestUtility.createWorkshop(true);
			Event__c workshop = listOfEvent[0];
			
			Price_Rules_And_Coupons__c pc0 = new Price_Rules_And_Coupons__c();
			pc0.recordTypeid = idPriceRuleRecordType;
			pc0.Workshop__c = workshop.id;
			pc0.Zip_Postal_Code__c = '3040';
			pc0.City__c = 'FREEMONdT';
			pc0.State__c = 'SC';
			pc0.Country__c = 'US';
			pc0.Is_Active__c = true;
			pc0.Workshop_Price__c = 40;
			
			listOfPriceCoupon.add(pc0);
			
			Price_Rules_And_Coupons__c pc = new Price_Rules_And_Coupons__c();
			pc.recordTypeid = idPriceRuleRecordType;
			pc.Workshop__c = workshop.id;
			pc.Valid_From_Date__c =  Date.today();
			pc.Valid_Till_Date__c =  Date.today();
			pc.Is_Active__c = true;
			pc.Workshop_Price__c = 50;
			
			listOfPriceCoupon.add(pc);
			
			Price_Rules_And_Coupons__c pc1 = new Price_Rules_And_Coupons__c();
			pc1.recordTypeid = idPriceRuleRecordType;
			pc1.Workshop__c = workshop.id;
			pc1.Zip_Postal_Code__c = '3020';
			pc1.City__c = 'FREEMONT';
			pc1.State__c = 'MN';
			pc1.Country__c = 'US';
			pc1.Is_Active__c = true;
			pc1.Workshop_Price__c = 50;
			pc1.Valid_From_Date__c =  Date.today();
			pc1.Valid_Till_Date__c =  Date.today();
			listOfPriceCoupon.add(pc1);
			
			
			Price_Rules_And_Coupons__c pc2 = new Price_Rules_And_Coupons__c();
			pc2.recordTypeid = idCouponRecordType;
			pc2.Coupon_Name_OR_ID__c = 'XXYY';
			pc2.Coupon_Type__c = 'Workshop';
			pc2.Coupon_Use__c = 'Single Use';
			pc2.Workshop__c = workshop.id;
			
			pc2.Discount_Type__c = 'Percentage';
			pc2.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			
			pc2.Zip_Postal_Code__c = '3020';
			pc2.City__c = 'FREEMONT';
			pc2.State__c = 'MN';
			pc2.Country__c = 'US';
			pc2.Is_Active__c = true;
			pc2.Workshop_Price__c = 50;
			
			listOfPriceCoupon.add(pc2);
			
			Price_Rules_And_Coupons__c pc3 = new Price_Rules_And_Coupons__c();
			pc3.recordTypeid = idCouponRecordType;
			pc3.Coupon_Name_OR_ID__c = 'XXYddY';
			pc3.Coupon_Type__c = 'Workshop';
			pc3.Coupon_Use__c = 'Single Use';
			pc3.Workshop__c = workshop.id;
			pc.Valid_From_Date__c =  Date.today();
			pc.Valid_Till_Date__c =  Date.today();
			pc3.Discount_Type__c = 'Percentage';
			pc3.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			pc3.Is_Active__c = true;
			pc3.Workshop_Price__c = 50;
			listOfPriceCoupon.add(pc3);
			
			
			Price_Rules_And_Coupons__c pc4 = new Price_Rules_And_Coupons__c();
			pc4.recordTypeid = idCouponRecordType;
			pc4.Coupon_Name_OR_ID__c = 'XXYjjjjY';
			pc4.Coupon_Type__c = 'Workshop';
			pc4.Coupon_Use__c = 'Single Use';
			pc4.Workshop__c = workshop.id;
			
			pc4.Discount_Type__c = 'Percentage';
			pc4.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			pc4.Valid_From_Date__c =  Date.today();
			pc4.Valid_Till_Date__c =  Date.today();
			pc4.Zip_Postal_Code__c = '30240';
			pc4.City__c = 'FREEMONddT';
			pc4.State__c = 'SC';
			pc4.Country__c = 'US';
			pc4.Is_Active__c = true;
			pc4.Workshop_Price__c = 50;
			
			Price_Rules_And_Coupons__c pc5 = new Price_Rules_And_Coupons__c();
			pc5.recordTypeid = idCouponRecordType;
			pc5.Coupon_Name_OR_ID__c = 'XXYjjjjdY';
			pc5.Coupon_Type__c = 'Workshop';
			pc5.Coupon_Use__c = 'Single Use';
			pc5.Workshop__c = workshop.id;
			
			pc5.Discount_Type__c = 'Percentage';
			pc5.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			pc5.City__c = 'FREEMONddT';
			pc5.State__c = 'SC';
			pc5.Country__c = 'US';
			pc5.Is_Active__c = true;
			pc5.Workshop_Price__c = 50;
			listOfPriceCoupon.add(pc5);
			
			Price_Rules_And_Coupons__c pc6 = new Price_Rules_And_Coupons__c();
			pc6.recordTypeid = idCouponRecordType;
			pc6.Coupon_Name_OR_ID__c = 'XXYjjjjddY';
			pc6.Coupon_Type__c = 'Workshop';
			pc6.Coupon_Use__c = 'Single Use';
			pc6.Workshop__c = workshop.id;
			
			pc6.Discount_Type__c = 'Percentage';
			pc6.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			pc6.State__c = 'SC';
			pc6.Country__c = 'US';
			pc6.Is_Active__c = true;
			pc6.Workshop_Price__c = 50;
			listOfPriceCoupon.add(pc6);
			
			Price_Rules_And_Coupons__c pc7 = new Price_Rules_And_Coupons__c();
			pc7.recordTypeid = idCouponRecordType;
			pc7.Coupon_Name_OR_ID__c = 'XXYjjjjdddddY';
			pc7.Coupon_Type__c = 'Workshop';
			pc7.Coupon_Use__c = 'Single Use';
			pc7.Workshop__c = workshop.id;
			
			pc7.Discount_Type__c = 'Percentage';
			pc7.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			pc7.Country__c = 'US';
			pc7.Is_Active__c = true;
			pc7.Workshop_Price__c = 50;
			listOfPriceCoupon.add(pc7);
			
			Price_Rules_And_Coupons__c pc8 = new Price_Rules_And_Coupons__c();
			pc8.recordTypeid = idCouponRecordType;
			pc8.Coupon_Name_OR_ID__c = 'XXYjjjpc8jdddddY';
			pc8.Coupon_Type__c = 'Workshop';
			pc8.Coupon_Use__c = 'Single Use';
			pc8.Workshop__c = workshop.id;
			
			pc8.Discount_Type__c = 'Percentage';
			pc8.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			pc8.Is_Active__c = true;
			pc8.Workshop_Price__c = 50;
			listOfPriceCoupon.add(pc8);
			
			Price_Rules_And_Coupons__c pc9 = new Price_Rules_And_Coupons__c();
			pc9.recordTypeid = idCouponRecordType;
			pc9.Coupon_Name_OR_ID__c = 'XXYjjssdY';
			pc9.Coupon_Type__c = 'Workshop';
			pc9.Coupon_Use__c = 'Single Use';
			pc9.Workshop__c = workshop.id;
			
			pc9.Discount_Type__c = 'Percentage';
			pc9.Discount_Percentage_OR_Flat_Price_OR_Day__c = 89;
			pc9.City__c = 'FREEMONddT';
			pc9.State__c = 'SC';
			pc9.Country__c = 'US';
			pc9.Is_Active__c = true;
			pc9.Valid_From_Date__c =  Date.today();
			pc9.Valid_Till_Date__c =  Date.today();
			pc9.Workshop_Price__c = 50;
			listOfPriceCoupon.add(pc9);
			
			List<Price_Rules_And_Coupons__c> listOfPriceCouponNew = new List<Price_Rules_And_Coupons__c>();
			listOfPriceCouponNew.addAll(listOfPriceCoupon);
			Database.insert (listOfPriceCoupon,false);
			Database.insert (listOfPriceCouponNew,false);
			Database.update ( listOfPriceCoupon,false);
			
		}
	 catch(Exception e){
	 	//same address existing error
	 } 
	 }
}
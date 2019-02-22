public class GenerateCouponsCtr {
    
    public Price_Rules_And_Coupons__c Coupon { get; set; }
    public Integer NoOfCoupon { get; set; }
    public Integer CouponCodeLength { get; set; }
    public List<Price_Rules_And_Coupons__c> GeneratedCoupons { get; set; }
    
    public GenerateCouponsCtr() {
        CouponCodeLength = 8;
        NoOfCoupon=0;
        Coupon = new Price_Rules_And_Coupons__c();
        Coupon.Coupon_Type__c = 'Subscription';
        Coupon.Coupon_Use__c = 'Single Use';
        Coupon.Discount_Type__c = 'Trial Days';
        Coupon.Is_Active__c = true;
        Coupon.RecordTypeId = Schema.SObjectType.Price_Rules_And_Coupons__c.getRecordTypeInfosByName().get('Coupon').getRecordTypeId();
 
        GeneratedCoupons = new List<Price_Rules_And_Coupons__c>();
    }
    
    public void generateAction() {
        
        if((Coupon.Valid_From_Date__c != null && Coupon.Valid_Till_Date__c == null) || (Coupon.Valid_From_Date__c == null && Coupon.Valid_Till_Date__c != null)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select either both date or leave them blank.'));
        } else if(Coupon.Coupon_Type__c == 'Subscription' && Coupon.Discount_Type__c != 'Trial Days') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select Discount type = Trial Days because we are not giving any discount on subscription based on money but on trial period.'));
        } else if(Coupon.Coupon_Type__c != 'Subscription' && Coupon.Discount_Type__c == 'Trial Days') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select Discount type as percentage or flat price not trial days'));
        } else if(Coupon.Discount_Type__c == 'Percentage' && Coupon.Discount_Percentage_OR_Flat_Price_OR_Day__c.round(System.RoundingMode.UP) > 100) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Coupon Discount in percentage should not more than 100 %'));
        } else if(String.isBlank(Coupon.Coupon_Type__c)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Coupon type is required field.'));
        } else if(Coupon.Coupon_Type__c == 'Subscription' && String.isBlank(Coupon.Subscription_Master__c) && String.isBlank(Coupon.Subscription__c)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select specific Subscription or Subscription Type'));
        } else if(Coupon.Coupon_Type__c == 'Subscription' && (String.isNotBlank(Coupon.CType_Product_Workshop__c) || String.isNotBlank(Coupon.Workshop__c))) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please clear out Workshop and CType Product Workshop as this coupon only application for Subscription'));
        } else if(Coupon.Coupon_Type__c == 'Workshop' && String.isBlank(Coupon.CType_Product_Workshop__c) && String.isBlank(Coupon.Workshop__c)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select Workshop or CType Product (Workshop)'));
        } else if(Coupon.Coupon_Type__c == 'Workshop' && (String.isNotBlank(Coupon.Subscription__c) || String.isNotBlank(Coupon.Subscription_Master__c))) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please clear out Subscription, Subscription Master field as coupon type is Workshop'));
        } else if(String.isBlank(Coupon.Discount_Type__c) || Coupon.Discount_Percentage_OR_Flat_Price_OR_Day__c == null || Coupon.Discount_Percentage_OR_Flat_Price_OR_Day__c.round(System.RoundingMode.UP) == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select Discount Type and enter Discount in price or percentage or day and should be greater than zero.'));
        } else if((Coupon.Subscription__c != null && Coupon.Subscription_Master__c != null)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select either Subscription or Subscription Master but not both.'));
        } else if((Coupon.Discount_Percentage_OR_Flat_Price_OR_Day__c == null || Coupon.Discount_Percentage_OR_Flat_Price_OR_Day__c ==0)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter trial days and should be greater than 0.'));
        } else if((NoOfCoupon == null || NoOfCoupon == 0)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter required coupons and should be greater than 0.'));
        }else{
             GeneratedCoupons = new List<Price_Rules_And_Coupons__c>();
            for (Integer i = 0; i < NoOfCoupon; i++) {
                Price_Rules_And_Coupons__c cCloneCopy = Coupon.clone(false, false, false, false);
                
                cCloneCopy.Coupon_Name_OR_ID__c = createRandomCode();
                GeneratedCoupons.add(cCloneCopy);
            }     
       }
       
    }
    
    public PageReference downloadCSVAction() {
        try{
        	insert GeneratedCoupons;
	        return Page.DownloadCoupons;
        } catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            return null;
       }
    }

    public String createRandomCode() {   
     String[] chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'.split('');
        String output = '';
        for (Integer i = 0; i < CouponCodeLength; i++) {
            Double d = math.random() * chars.size();
            String c = chars[d.intValue()];
            if(math.mod(i,4) == 0 && i > 0) {
                output += '-';
            }
            output += c;
        }
        return output ;
    }
}
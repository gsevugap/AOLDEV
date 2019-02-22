public abstract class StripeAPI {
	
    private static Stripe_Settings__mdt stripeSettingObj= null;
    	
    private static Stripe_Settings__mdt getStripeSettingObject() {
        if(stripeSettingObj != null ){
            return stripeSettingObj;
        }else {
      		List<Stripe_Settings__mdt> listOfSettings = [Select id, Stripe_api_base_url__c, Stripe_api_version__c, 
	 	           										  Stripe_Publishable_Key__c, Stripe_Secret_Key__c from Stripe_Settings__mdt limit 1];
            if(Test.isRunningTest()){
            	listOfSettings = new List<Stripe_Settings__mdt>();
            	Stripe_Settings__mdt setting = new Stripe_Settings__mdt
            	(
            		Stripe_api_base_url__c ='http://stripe.com',
            		Stripe_api_version__c ='v1',
            		Stripe_Publishable_Key__c ='xxssssss',
            		Stripe_Secret_Key__c ='testtest'
            	 );
            	listOfSettings.add(setting); 
            }	 	           										  
            if(listOfSettings.size() > 0){
               stripeSettingObj = listOfSettings[0];
                return stripeSettingObj;
            }else {
                throw new StripeException('Please setup the stripe Settings first');
            }      
        }    
    }
    
    public static String getStripeURL(){
        Stripe_Settings__mdt stripeSetting = getStripeSettingObject();
        if(String.isNotBlank(stripeSetting.Stripe_api_base_url__c) && String.isNotBlank(stripeSetting.Stripe_api_version__c)){
            return stripeSetting.Stripe_api_base_url__c+'/'+stripeSetting.Stripe_api_version__c;
        } else {
            throw new StripeException('Please setup the stripe Settings for URL and version');
        }
    }
    private static String getStripePublishableKey(){
         Stripe_Settings__mdt stripeSetting = getStripeSettingObject();
         if(String.isNotBlank(stripeSetting.Stripe_Publishable_Key__c)){
            return stripeSetting.Stripe_Publishable_Key__c;
        } else {
            throw new StripeException('Please setup the stripe Settings for Publishable Key');
        }
    }
    private static String getStripeSecretKey(){
         Stripe_Settings__mdt stripeSetting = getStripeSettingObject();
         if(String.isNotBlank(stripeSetting.Stripe_Secret_Key__c)){
            return stripeSetting.Stripe_Secret_Key__c;
        } else {
            throw new StripeException('Please setup the stripe Settings for Secret Key');
        }
    }
    
    public static String getStripAuthorizationHeader(){
        Blob headerValue = Blob.valueOf(getStripeSecretKey() + ':');
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		return authorizationHeader;
    }
    
    private static String blankValue(String s1) {
        if(String.isBlank(s1)){
            return '';
        }
        return s1;
	}
    
    public static String urlify(Map<String, String> params) {
		String url = '&';
		for (String key : params.keySet()) {
			url += EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(blankValue(params.get(key)), 'UTF-8') + '&';
		}
		return url;
	}
    
}
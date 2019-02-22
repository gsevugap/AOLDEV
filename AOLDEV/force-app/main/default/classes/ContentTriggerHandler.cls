public class ContentTriggerHandler {
    public static void beforeInsert(List<Content__c> listOfContent , Boolean IsFromUpdate){
        System.debug('listOfContent'+listOfContent);
        Map<String, Content__c>  mapOfValidContent= getValidContents(listOfContent, IsFromUpdate);
        if(mapOfValidContent.keySet().size() > 0){
        	Map<String, Product2>  mapOfProduct2AndContentfulId = getCreatableProducts(mapOfValidContent.values());
            System.debug('mapOfProduct2AndContentfulId'+mapOfProduct2AndContentfulId);
        	insert mapOfProduct2AndContentfulId.values();    
            for(String key : mapOfValidContent.keyset()){
            	Content__c content =  mapOfValidContent.get(key);
                System.debug(' ==== content === '+content);
	            content.Product__c = mapOfProduct2AndContentfulId.get(key).id;
        	}
           List<PricebookEntry> listOfPriceBookEntry = getCreatableListOfPriceBookEntry(mapOfValidContent, mapOfProduct2AndContentfulId);
           System.debug(listOfPriceBookEntry); 
           insert  listOfPriceBookEntry;
        }
        if(!IsFromUpdate) {
            teacherMapping(listOfContent);
        }
    }
    private static void teacherMapping(List<Content__c> listOfContent) {
        Map<Id, List<Content__c>> mapOfPrimaryTeacher = new Map<Id, List<Content__c>>();
        Map<Id, List<Content__c>> mapOfCoTeacher1 = new Map<Id, List<Content__c>>();
        Map<Id, List<Content__c>> mapOfCoTeacher2 = new Map<Id, List<Content__c>>();
        for(Content__c contentObj : listOfContent) {
            if(contentObj.Primary_Teacher_Master__c != null) {
                if(!mapOfPrimaryTeacher.containsKey(contentObj.Primary_Teacher_Master__c)) {
                    mapOfPrimaryTeacher.put(contentObj.Primary_Teacher_Master__c, new List<Content__c>());
                }
                mapOfPrimaryTeacher.get(contentObj.Primary_Teacher_Master__c).add(contentObj);
            } else {
                contentObj.Primary_Teacher__c = null;
            }
            if(contentObj.Co_Teacher_M_1__c != null) {
                if(!mapOfCoTeacher1.containsKey(contentObj.Co_Teacher_M_1__c)) {
                    mapOfCoTeacher1.put(contentObj.Co_Teacher_M_1__c, new List<Content__c>());
                }
                mapOfCoTeacher1.get(contentObj.Co_Teacher_M_1__c).add(contentObj);
            } else {
                contentObj.Co_Teacher_1__c = null;
            }
            if(contentObj.Co_Teacher_M_2__c != null) {
                if(!mapOfCoTeacher2.containsKey(contentObj.Co_Teacher_M_2__c)) {
                    mapOfCoTeacher2.put(contentObj.Co_Teacher_M_2__c, new List<Content__c>());
                }
                mapOfCoTeacher2.get(contentObj.Co_Teacher_M_2__c).add(contentObj);
            } else {
                contentObj.Co_Teacher_2__c = null;
            }
        }
        for(Account accObj : [SELECT Id, Teacher_Master__c FROM Account WHERE Teacher_Master__c IN : mapOfPrimaryTeacher.keySet()
                                        OR Teacher_Master__c IN : mapOfCoTeacher1.keySet()
                                        OR Teacher_Master__c IN : mapOfCoTeacher2.keySet()]) {
            if(mapOfPrimaryTeacher.containsKey(accObj.Teacher_Master__c)) {
                for(Content__c contentObj : mapOfPrimaryTeacher.get(accObj.Teacher_Master__c)) {
                    contentObj.Primary_Teacher__c = accObj.id;
                }
                mapOfPrimaryTeacher.remove(accObj.Teacher_Master__c);
            }
            if(mapOfCoTeacher1.containsKey(accObj.Teacher_Master__c)) {
                for(Content__c contentObj : mapOfCoTeacher1.get(accObj.Teacher_Master__c)) {
                    contentObj.Co_Teacher_1__c = accObj.id;
                }
                mapOfCoTeacher1.remove(accObj.Teacher_Master__c);
            }
            if(mapOfCoTeacher2.containsKey(accObj.Teacher_Master__c)) {
                for(Content__c contentObj : mapOfCoTeacher2.get(accObj.Teacher_Master__c)) {
                    contentObj.Co_Teacher_2__c = accObj.id;
                }
                mapOfCoTeacher2.remove(accObj.Teacher_Master__c);
            }
        }
        for(List<Content__c> contentList : mapOfPrimaryTeacher.values()) {
            for(Content__c contentObj : contentList) {
                contentObj.Primary_Teacher__c = null;
            }
        }
        for(List<Content__c> contentList : mapOfCoTeacher1.values()) {
            for(Content__c contentObj : contentList) {
                contentObj.Co_Teacher_1__c = null;
            }
        }
        for(List<Content__c> contentList : mapOfCoTeacher2.values()) {
            for(Content__c contentObj : contentList) {
                contentObj.Co_Teacher_2__c = null;
            }
        }
    }
    
    public static void beforeUpdate( Map<Id, Content__c> mapOfNewContent, Map<Id, Content__c> mapOfOldContent){
        List<Content__c> listOfContentWhichProductsNeedsToCreate = new List<Content__c>();
        Map<Id, Decimal> mapOfValidUpdatedProductPrice = new Map<Id, Decimal>();
        Map<Id, String> mapOfValidCategoryUpdateForProduct = new Map<Id, String>();
        for(String key : mapOfOldContent.keyset()){
            Content__c oldContent = mapOfOldContent.get(key);
            Content__c newContent = mapOfNewContent.get(key); 

            if(oldContent.Product__c == null && !newContent.Is_Free__c && newContent.price__c !=null && newContent.price__c > 0){
            	listOfContentWhichProductsNeedsToCreate.add(newContent);
            }

            if(oldContent.Product__c != null && oldContent.price__c != newContent.price__c){
                mapOfValidUpdatedProductPrice.put(newContent.Product__c, newContent.price__c);
            }
            if(oldContent.Product__c !=null && oldContent.subscription_category__c != newContent.subscription_category__c){
                mapOfValidCategoryUpdateForProduct.put(newContent.Product__c, newContent.subscription_category__c);
            }


        }
        
        if(listOfContentWhichProductsNeedsToCreate.size()>0){
            beforeInsert(listOfContentWhichProductsNeedsToCreate , true);
        }

        if(mapOfValidCategoryUpdateForProduct.keyset().size() > 0){
        	List<Product2> listOfProducts = new List<Product2>();
        	for(String key : mapOfValidCategoryUpdateForProduct.keyset()){
        		Product2 pr = new Product2(id = key, Product_Subscription_Category__c = mapOfValidCategoryUpdateForProduct.get(key));
        		listOfProducts.add(pr);
        	}
        	update listOfProducts;
        }

        if(mapOfValidUpdatedProductPrice.keyset().size() > 0){
            List<PricebookEntry> listOfPriceBookEntry = [select id, UnitPrice, Product2Id from PricebookEntry where Product2Id =: mapOfValidUpdatedProductPrice.keyset()];
            for(PricebookEntry pbe :listOfPriceBookEntry){
                Decimal updatedPrice = mapOfValidUpdatedProductPrice.get(pbe.Product2Id);
                pbe.UnitPrice = updatedPrice;
            } 
           update listOfPriceBookEntry; 
        }
        List<Content__c> listOfContent = mapOfNewContent.values();
        teacherMapping(listOfContent);
    }
    
    //Return only those object which synced from contentful -
    private static Map<String, Content__c> getValidContents(List<Content__c> listOfContent, Boolean isFromUpdate){
        Map<String, Content__c> mapOfValidContent = new Map<String, Content__c>();
        for(Content__c content : listOfContent){
            if(!isFromUpdate){
				content.Is_Free__c = true ; // initially we are assuming that all record  are free with draft status - a user later point of time can uncheck and give price                
            }
            if(String.isNotBlank(content.Contentful_Id__c) && !content.Is_Free__c){
                mapOfValidContent.put(content.Contentful_Id__c, content);
            }
        }
        return mapOfValidContent;
    }
    
    private static Map<String, Product2> getCreatableProducts(List<Content__c> listOfContent){

    	Map<String, String> mapOfRecordTypeNameAndProductType = new Map<String, String> {
    		'Course'=> 'Course', 'Meditation Session'=> 'Meditation', 'Microlearning'=> 'Microlearning', 'Daily Quote'=> 'Daily Quote'
    	};

        System.debug('mapOfRecordTypeNameAndProductType'+mapOfRecordTypeNameAndProductType);
		Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.content__c.getRecordTypeInfosByName();
		Map<Id, String> mapOfRecordTypeIdAndName = new Map<Id, String>();
		for(String  recordTypeName : recordTypes.keySet()){
			String recordTypeId = recordTypes.get(recordTypeName).getRecordTypeId();
			mapOfRecordTypeIdAndName.put(recordTypeId,recordTypeName);
		}

        System.debug('mapOfRecordTypeIdAndName'+mapOfRecordTypeIdAndName);

        Map<String, Product2>  mapOfProduct2AndContentfulId = new Map<String, Product2>();
        Id recordTypeIdForProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
                      .get('Product').getRecordTypeId();
         for(Content__c content : listOfContent){

         	String contentRecordTypeId = content.recordTypeId;
         	String contentType = mapOfRecordTypeIdAndName.get(contentRecordTypeId);
                    System.debug('contentType'+contentType); 
         	String productType = mapOfRecordTypeNameAndProductType.get(contentType) ;
                                System.debug('productType'+productType);  
            String contentfulId = content.Contentful_Id__c;
            String productName = String.isNotBlank(content.Title__c) ? content.Title__c :  contentfulId;
            productName =  productName.length() > 255 ? productName.subString(0,255): productName;
            Product2 pr = new Product2(ProductCode  = contentfulId, IsActive  = true, 
                                       	name = productName, Product_Subscription_Category__c = content.subscription_category__c, Product_Type__c  =productType, RecordtypeId = recordTypeIdForProduct );
             mapOfProduct2AndContentfulId.put(contentfulId, pr);
        }
        return mapOfProduct2AndContentfulId;
    }
    
    private static List<PricebookEntry> getCreatableListOfPriceBookEntry(Map<String, Content__c> mapOfValidContent, Map<String, Product2>  mapOfProduct2AndContentfulId){
        	List<Pricebook2> listOfPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];
        	List<PricebookEntry> listOfPriceBookEntry = new List<PricebookEntry>();
        	if(listOfPriceBook.size() > 0 ){ 
                String priceBookId = listOfPriceBook.get(0).id;    
                for(String key : mapOfValidContent.keyset()){
                    Content__c content =  mapOfValidContent.get(key);
                    Product2 pr = mapOfProduct2AndContentfulId.get(key);
                    PricebookEntry pbe = new PricebookEntry(Pricebook2Id  =priceBookId, Product2Id  =pr.id, UnitPrice = content.price__c, IsActive = true );
                    System.debug('pbe'+pbe);
                    listOfPriceBookEntry.add(pbe);
                }
                return listOfPriceBookEntry;
            }else{
                throw new ContnetTriggerHandlerException(' No standard price book available ');
            }
    }
    
    class ContnetTriggerHandlerException extends Exception{}  
}
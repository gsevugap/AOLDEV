public class EventTriggerHandler {

    
    public static void beforeInsert(List<Event__c> listOfEvent){
         updateDateTimeFieldForHeroku(listOfEvent);
	     processValidWorkshops(listOfEvent);
    }
    public static void afterInsert(List<Event__c> listOfEvent){
	     processAddOnProducts(listOfEvent);
    }
    
    // forcefully udating allAttendee record to excuting sharing flow.
    public static void afterUpdate(Map<Id, Event__c> mapOfOldEvent, Map<Id, Event__c> mapOfNewEvent) {
        Set<Id> requiredUpdateIds = new Set<Id>();
        for(Event__c eventObj : mapOfOldEvent.values()) {
            if((eventObj.Primary_Teacher__c != mapOfNewEvent.get(eventObj.Id).Primary_Teacher__c && mapOfNewEvent.get(eventObj.Id).Primary_Teacher__c != null)
                || (eventObj.Co_Teacher_1__c != mapOfNewEvent.get(eventObj.Id).Co_Teacher_1__c && mapOfNewEvent.get(eventObj.Id).Co_Teacher_1__c != null)
                || (eventObj.Co_Teacher_2__c != mapOfNewEvent.get(eventObj.Id).Co_Teacher_2__c && mapOfNewEvent.get(eventObj.Id).Co_Teacher_2__c != null)
                || (eventObj.Organizer__c != mapOfNewEvent.get(eventObj.Id).Organizer__c && mapOfNewEvent.get(eventObj.Id).Organizer__c != null)) {
                requiredUpdateIds.add(eventObj.Id);
            }
        }
        List<Attendee__c> allAttendee = [SELECT Id, Is_updated_by_BG_Job__c FROM Attendee__c WHERE Event__c IN: requiredUpdateIds];
        for(Attendee__c AttendeeObj : allAttendee) {
            AttendeeObj.Is_updated_by_BG_Job__c = !AttendeeObj.Is_updated_by_BG_Job__c;
        }
        if(allAttendee.size() > 0) {
            update allAttendee;
        }
    }
    
    public static void beforeUpdate(Map<Id, Event__c> mapOfOldEvent, Map<Id, Event__c> mapOfNewEvent){
       updateDateTimeFieldForHeroku(mapOfNewEvent.values()); 
       List<Event__c> listOfValidWorkshopForCtypeUpdate = new List<Event__c>(); 
       Map<Id, Decimal> mapOfWorkShopIdAndUpdatedPrice = new Map<Id, Decimal>();

       for(String key : mapOfOldEvent.keyset()){
           Event__c oldEvent = mapOfOldEvent.get(key);
           Event__c newEvent = mapOfNewEvent.get(key);
           if(oldEvent.Product__c == null ||  (oldEvent.CType_Id__c != newEvent.CType_Id__c) ){
               listOfValidWorkshopForCtypeUpdate.add(newEvent);
           }
           if(oldEvent.Workshop_Course_Expense__c != newEvent.Workshop_Course_Expense__c){
               mapOfWorkShopIdAndUpdatedPrice.put(newEvent.id, newEvent.Workshop_Course_Expense__c);
           }
       }
       if(listOfValidWorkshopForCtypeUpdate.size()>0){
           processValidWorkshops(listOfValidWorkshopForCtypeUpdate);            
       }
       if(mapOfWorkShopIdAndUpdatedPrice.keyset().size() > 0){
		
           Map<Id, Decimal> mapOfProductIdAndUpdatedPrice = new Map<Id, Decimal>(); 
           Map<Id,Id> mapOfWorkshopIdAndProductId = new Map<Id,Id>();
           // update existing addOn product price
           List<Product2> listOfAddOnProducts = [Select id, workshop__c from Product2 where Is_Synced_With_External_System__c = true and workshop__c =: mapOfWorkShopIdAndUpdatedPrice.keySet()];
			
           for(Product2 pr : listOfAddOnProducts){
               mapOfWorkshopIdAndProductId.put(pr.Workshop__c, pr.id);
               Decimal updatedPrice = mapOfWorkShopIdAndUpdatedPrice.get(pr.Workshop__c);
               mapOfProductIdAndUpdatedPrice.put(pr.id, updatedPrice);
           }
           List<PricebookEntry> listOfPriceBookEntry = [select id, UnitPrice, Product2Id from PricebookEntry where Product2Id =:mapOfProductIdAndUpdatedPrice.keySet()];
           for(PricebookEntry pbe :listOfPriceBookEntry){
               Decimal updatedPrice = mapOfProductIdAndUpdatedPrice.get(pbe.Product2Id);
               pbe.UnitPrice = updatedPrice;
           } 
           update listOfPriceBookEntry; 
           
           List<Event__c> listOfWorkshopForCreatingAddOnProduct = new List<Event__c> ();
           for(String s : mapOfWorkShopIdAndUpdatedPrice.keySet()){
               if(!mapOfWorkshopIdAndProductId.keySet().contains(s)){
                    Event__c wr = mapOfNewEvent.get(s);
                   if(wr.Workshop_Course_Expense__c > 0){
                    	listOfWorkshopForCreatingAddOnProduct.add(mapOfNewEvent.get(s));                      
                   	}	
               }
           }
           processAddOnProducts(listOfWorkshopForCreatingAddOnProduct); // for new addon product creation, This statement of those workshop which initally have 0 expense so no record but after update in harmony they having some expense price. so we need to create that product.
			
        }
	
    }

    
    private static void processValidWorkshops(List<Event__c> listOfEvent){
        List<Event__c> listOfEvents= getValidWorkshopsBasedOnCtype(listOfEvent);
        if(listOfEvents.size() > 0){
            Map<String, Id> mapOfCtypeIdAndProductId = getCtypeProducts(listOfEvents);
            for(Event__c workshop : listOfEvents){
	            workshop.Product__c = mapOfCtypeIdAndProductId.get(workshop.CType_Id__c);
        	}            
        }
    }
    
    private static void processAddOnProducts(List<Event__c> listOfEvent) {
        Map<String, Event__c> mapOfValidWorkshop= getValidWorkshopsMapBasedOnCtype(listOfEvent);
        if(mapOfValidWorkshop.keySet().size() > 0){
            Map<String, Product2>  mapOfAddOnProduct2AndWorkshopId = getCreatableAddOnProducts(mapOfValidWorkshop.values());
            if(mapOfAddOnProduct2AndWorkshopId.keySet().size()>0){
                insert mapOfAddOnProduct2AndWorkshopId.values();
                List<PricebookEntry> listOfPriceBookEntry = getCreatableListOfPriceBookEntry(mapOfValidWorkshop, mapOfAddOnProduct2AndWorkshopId);
                insert  listOfPriceBookEntry;
            } 
        }         
    }
    
    //Return only those object which synced from harmony / or created as workshop with valid CtypeId - No Meetup 
    private static List<Event__c> getValidWorkshopsBasedOnCtype(List<Event__c> listOfEvent){
        List<Event__c> listOfEvents = new List<Event__c>();
        for(Event__c workshop : listOfEvent){
            if(String.isNotBlank(workshop.CType_Id__c)){
              listOfEvents.add(workshop);
            }
        }
        return listOfEvents;
    }
    private static Map<String, Event__c> getValidWorkshopsMapBasedOnCtype(List<Event__c> listOfEvent){
        Map<String, Event__c> mapOfValidEvents = new Map<String, Event__c>();
        for(Event__c workshop : listOfEvent){
            if(String.isNotBlank(workshop.CType_Id__c)){
              mapOfValidEvents.put(workshop.id, workshop);
            }
        }
        return mapOfValidEvents;
    }
    
    private static Map<String,Id> getCtypeProducts(List<Event__c> listOfEvent){
        List<String> listOfCType = new List<String>();
        for(Event__c workshop : listOfEvent){
            if(String.isNotBlank(workshop.CType_Id__c)){
            	listOfCType.add(workshop.CType_Id__c);    
            }
        }
        List<Product2> existingProducts = [Select id,CType_Id__c from Product2 where Product_Type__c = 'Workshop' and CType_Id__c =: listOfCType];
        Map<String,Id> mapOfProductCodeAndId = new Map<String,Id>();
        for(Product2 p : existingProducts){
			mapOfProductCodeAndId.put(p.CType_Id__c, p.id);
        }
       return mapOfProductCodeAndId;
    }
    
    private static Map<String, Product2> getCreatableAddOnProducts(List<Event__c> listOfEvent){
        Map<String, Product2>  mapOfProduct2AndWorkshopId = new Map<String, Product2>();
        Id recordTypeIdForProductAddOn = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
                      .get('Add_On_Product').getRecordTypeId();
         for(Event__c workshop : listOfEvent){
             if(workshop.Workshop_Course_Expense__c > 0) {
                String productName = 'Workshop expense - '; 
                productName += String.isNotBlank(workshop.Title__c) ? workshop.Title__c :  workshop.id;
                productName =  productName.length() > 255 ? productName.subString(0,255): productName;
                Product2 pr = new Product2(IsActive  = true, Workshop__c  = workshop.id,
                                            name = productName, Product_Subscription_Category__c = 'None', Is_Synced_With_External_System__c  = true,  Product_Type__c  ='Workshop Add On', RecordtypeId = recordTypeIdForProductAddOn );
                 mapOfProduct2AndWorkshopId.put(workshop.id, pr);
             }
        }
        return mapOfProduct2AndWorkshopId;
    }
    
    private static List<PricebookEntry> getCreatableListOfPriceBookEntry(Map<String, Event__c> mapOfValidWorkshop, Map<String, Product2>  mapOfAddOnProduct2AndWorkshopId){
        List<Pricebook2> listOfPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];
        List<PricebookEntry> listOfPriceBookEntry = new List<PricebookEntry>();
        if(listOfPriceBook.size() > 0 ){ 
            String priceBookId = listOfPriceBook.get(0).id;    
            for(String key : mapOfValidWorkshop.keyset()){
                Event__c workshop =  mapOfValidWorkshop.get(key);
                Product2 pr = mapOfAddOnProduct2AndWorkshopId.get(key);
                if(pr!=null){
               		PricebookEntry pbe = new PricebookEntry(Pricebook2Id  =priceBookId, Product2Id  =pr.id, UnitPrice = workshop.Workshop_Course_Expense__c, IsActive = true );
                	listOfPriceBookEntry.add(pbe);     
                }
               
            }
            return listOfPriceBookEntry;
        }else{
            throw new EventTriggerException(' No standard price book available ');
        }
    }
   
    private static void updateDateTimeFieldForHeroku(List<Event__c> listOfEvent){
        
        for(Event__c e : listOfEvent){
            String timeZoneId = e.Timezone__c;
            
            //for workshop
            Date startDate = e.Event_Start_Date__c;
            Date endDate = e.Event_End_Date__c;
			Time weekdayStartTime = e.Event_Start_Time_Weekday__c !=null ?e.Event_Start_Time_Weekday__c : Time.newInstance(00, 00 , 00 , 00);
           	Time weekdayEndTime = e.Event_End_Time_Weekday__c !=null ?e.Event_End_Time_Weekday__c : Time.newInstance(00, 00 , 00 , 00);
            Time weekendStartTime = e.Event_Start_Time_Weekend__c !=null ?e.Event_Start_Time_Weekend__c : Time.newInstance(00, 00 , 00 , 00);
           	Time weekendEndTime = e.Event_End_Time_Weekend__c   !=null ?e.Event_End_Time_Weekend__c : Time.newInstance(00, 00 , 00 , 00);
            if(String.isNotEmpty(timeZoneId) && startDate!=null && endDate != null){
                Timezone tz = Timezone.getTimeZone(timeZoneId);
                DateTime gmtDateTime =  datetime.now();
                Long timeZoneOffset = tz.getOffset(gmtDateTime); //miliSeconds
                Long  dateTimeInMiliSeconds = 0;
                
                Datetime weekDayStartDateTime = Datetime.newInstanceGmt(startDate, weekdayStartTime);
                dateTimeInMiliSeconds = weekDayStartDateTime.getTime();
                dateTimeInMiliSeconds = dateTimeInMiliSeconds - timeZoneOffset;
                weekDayStartDateTime = DateTime.newInstance(dateTimeInMiliSeconds);
                e.Event_Start_Date_Time_WeekDay_GMT__c   = weekDayStartDateTime;
                
				Datetime weekDayEndDateTime = Datetime.newInstanceGmt(endDate, weekdayEndTime);
                dateTimeInMiliSeconds = weekDayEndDateTime.getTime();
                dateTimeInMiliSeconds = dateTimeInMiliSeconds - timeZoneOffset;
                weekDayEndDateTime = DateTime.newInstance(dateTimeInMiliSeconds);
				e.Event_End_Date_Time_WeekDay_GMT__c  = weekDayEndDateTime;
                
				Datetime weekEndStartDateTime = Datetime.newInstanceGmt(startDate, weekendStartTime);
                dateTimeInMiliSeconds = weekEndStartDateTime.getTime();
                dateTimeInMiliSeconds = dateTimeInMiliSeconds - timeZoneOffset;
                weekEndStartDateTime = DateTime.newInstance(dateTimeInMiliSeconds);
                e.Event_Start_Date_Time_WeekEnd_GMT__c   = weekEndStartDateTime;
                
				Datetime weekEndEndDateTime = Datetime.newInstanceGmt(endDate, weekendEndTime);
                dateTimeInMiliSeconds = weekEndEndDateTime.getTime();
                dateTimeInMiliSeconds = dateTimeInMiliSeconds - timeZoneOffset;
                weekEndEndDateTime = DateTime.newInstance(dateTimeInMiliSeconds);
                e.Event_End_Date_Time_WeekEnd_GMT__c   = weekEndEndDateTime;
            }
          
          //for meetup
           Date meetupStartDate = e.Meetup_Start_Date__c;
           Time meetupStartTime = e.Meetup_Start_Time__c !=null ?e.Meetup_Start_Time__c : Time.newInstance(00, 00 , 00 , 00);
           if(String.isNotEmpty(timeZoneId) && meetupStartDate!=null){
           	 	Timezone tz = Timezone.getTimeZone(timeZoneId);
                DateTime gmtDateTime =  datetime.now();
                Long timeZoneOffset = tz.getOffset(gmtDateTime); //miliSeconds
                Long  dateTimeInMiliSeconds = 0;
                
                Datetime meetupStartDateTimeGMT = Datetime.newInstanceGmt(meetupStartDate, meetupStartTime);
                dateTimeInMiliSeconds = meetupStartDateTimeGMT.getTime();
                dateTimeInMiliSeconds = dateTimeInMiliSeconds - timeZoneOffset;
                meetupStartDateTimeGMT = DateTime.newInstance(dateTimeInMiliSeconds);
                e.Meetup_Start_Date_Time_GMT__c   = meetupStartDateTimeGMT;
           	
           }
            
        }
        
    }

    class EventTriggerException extends Exception{} 
    
    
}
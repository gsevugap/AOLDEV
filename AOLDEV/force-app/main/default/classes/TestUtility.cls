public with sharing class TestUtility {
    
    public static List<Teacher_Master__c> createTeacherTemp(Boolean shouldCreate){
        List<Teacher_Master__c> listOfTeacherTemp = new List<Teacher_Master__c>();
        for(integer i=0; i<2; i++){
            listOfTeacherTemp.add( new Teacher_Master__c( name ='testName'+i, Account_Type__c = 'Teacher', First_Name__c = 'testFirstName'+i, last_name__c  = 'testLastName'+i, email__c  = i+'test@aol.com')); 
        }
        if(shouldCreate){
         insert listOfTeacherTemp;
        }
     return listOfTeacherTemp;
    }
    
    public static List<Account> createPersonAccounts(Boolean shouldCreate){
        
        List<Account> listOfAccount = new List<Account>();
        for(integer i=0; i<10; i++){
            listOfAccount.add( new Account( External_Id__c ='test'+i, FirstName= 'testFirstName'+i, LastName = 'testLastName'+i, personEmail = i+'test@aol.com')); 
        }
        if(shouldCreate){
         insert listOfAccount;
        }
     return listOfAccount;
    }
    
    public static List<Teacher_Master__c> createTeacherMaster(Boolean shouldCreate){
        
        List<Teacher_Master__c> listOfTeacherMaster = new List<Teacher_Master__c>();
        for(integer i=0; i<10; i++){
            listOfTeacherMaster.add( new Teacher_Master__c( Name__c ='test'+i, First_Name__c= 'testFirstName'+i, last_Name__c = 'testLastName'+i, email__c = i+'test@aol.com')); 
        }
        if(shouldCreate){
         insert listOfTeacherMaster;
        }
        return listOfTeacherMaster;
    }
    
    public static String getRecordType(String recordTypeDeveloperName, String ObjectName){
        List<RecordType> listOfRecordType = [select Id from RecordType where developername =:recordTypeDeveloperName and SobjectType =: ObjectName];
        if(listOfRecordType.size() > 0){
            return listOfRecordType[0].id;
        }
        return null;
    }
    
    public static List<Event__c> createWorkshop(Boolean shouldCreate){
        
    Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true
    );
    update standardPricebook;
    
     String workshopRecordTypeId = getRecordType('Workshop', 'Event__c');
    List<Event__c> listOfWorkshop = new List<Event__c>();
     for(integer i=0; i<10; i++){
      Event__c workshop = new Event__c();
      workshop.recordtypeid = workshopRecordTypeId;
      workshop.event_start_time_weekday__c = Time.newInstance(1, 2, 3, 4);
      workshop.event_end_time_weekday__c= Time.newInstance(1, 2, 3, 4);
      workshop.event_start_time_weekend__c = Time.newInstance(1, 2, 3, 4);
      workshop.event_end_time_weekend__c = Time.newInstance(1, 2, 3, 4);
      workshop.event_start_date__c =  Date.today();
      workshop.event_end_date__c= Date.today();
      workshop.workshop_last_updated_date__c = DateTime.now();
      workshop.workshop_created_date__c = DateTime.now();
      workshop.workshop_contact_name__c = 'test';
      workshop.geolocation__longitude__s = null;
      workshop.full_address__c = ' xyz, xyz ,xyz';
      workshop.address_short__c = ' xyz, xyz ,xyz';
      workshop.street_address_1__c = ' xyz, xyz ,xyz';
      workshop.street_address_2__c = ' xyz, xyz ,xyz';
      workshop.city__c = 'Eugene';
      workshop.state__c = 'OR';
      workshop.zip_postal_code__c= '33190';
      workshop.country__c = 'US';
      workshop.email__c = 'test@test.gmail.com';
      workshop.workshop_id__c = '689946'+i;
      workshop.workshop_teacher_info__c = '[]';
      workshop.workshop_course_expense__c = 300.40;
      workshop.workshop_course_fee__c = 200.30;
      workshop.timezone__c = 'America/New_York';
      workshop.center_node_id__c = '612349';
      workshop.ctype_id__c = '12371';
      listOfWorkshop.add(workshop);
     }
     if(shouldCreate){
        insert listOfWorkshop;
     }
     
     return listOfWorkshop;
    } 
    
    public static List<Content__C> createContent(Boolean shouldCreate){
        Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true
    );
    update standardPricebook;
       String contentRecordTypeId = getRecordType('Meditation_Session', 'Content__c');      
       List<Content__c> listOfContent = new List<Content__c> ();
       for(integer i=0; i<10; i++){
      if(math.mod(i, 2) == 0){
         Content__c content = new Content__c();
          content.Is_Free__c = false;
          content.Subscription_Category__c = 'Digital';
          content.Price__c = 9.0;       
          content.title__c = 'This is test title';
          content.content_type__c = 'Text';
          content.category__c= 'Happiness;Stress;Productivity;Daily Practice';
          content.description__c= 'This is test title';
          content.cover_image__c= 'This is test title';
          content.contentful_id__c= '6bIgkSbztSk6uCisCMuE0C'+i;
          content.recordtypeid = contentRecordTypeId;
          content.contentful_status__c = 'publish';
          listOfContent.add(content);
      } else{
         Content__c content = new Content__c();
          content.Is_Free__c = true;
          content.title__c = 'This is test title';
          content.content_type__c = 'Text';
          content.category__c= 'Happiness;Stress;Productivity;Daily Practice';
          content.description__c= 'This is test title';
          content.cover_image__c= 'This is test title';
          content.contentful_id__c= '6bIgkSbztSk6uCisCMuE0C'+i;
          content.recordtypeid = contentRecordTypeId;
          content.contentful_status__c = 'publish';
          listOfContent.add(content);
      }     
     
     }
     
     if(shouldCreate){
      insert listOfContent;
     }      
     
     return listOfContent;              
    }
    
    public static List<Attendee__c> createAttendees(List<Account> listOfPersonaccount, List<Event__c> listOfEvents, Boolean shouldCreate){
    	List<Attendee__c> listOfAttendee = new List<Attendee__c>();
    	for(Event__c e : listOfEvents){
    		for(Account acc : listOfPersonaccount){
    			Attendee__c att = new Attendee__c();
    			att.Attendee__c = acc.id;
    			att.RSVP__c = 'Yes';
    			att.Event__c = e.id;
    			att.Date__c = Date.today();
    			att.Payment_Status__c = 'None';
    			att.Attended__c = true;
    			listOfAttendee.add(att);
    		}	
    	
    	}
    	if(shouldCreate){
    		insert listOfAttendee;
    	}
    	return listOfAttendee;
    	
    }
    
    public static List<Content_Activity__c> createContentActivity(List<Content__c> listOfContent, List<Account> listOfPersonAccount , Boolean shouldCreate){
    	List<Content_Activity__c> listOfContentActivity = new List<Content_Activity__c>();
    	for(Content__c c : listOfContent){
    		for(Account acc : listOfPersonAccount){
    			Content_Activity__c ca = new Content_Activity__c();
    			ca.Content__c = c.id;
    			ca.Status__c = 'Completed';
    			ca.Member__c = acc.id;
    			listOfContentActivity.add(ca);
    		}
    	}
    	
    	if(shouldCreate){
    		insert listOfContentActivity;
    	}
    	
    	return listOfContentActivity;
    
    }
    
    public static Boolean wasMessageAdded(ApexPages.Message message) {
        Boolean messageFound = false;
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        for(ApexPages.Message msg : pageMessages) {
        if(msg.getSummary() == message.getSummary()
            && msg.getDetail() == message.getDetail()
            && msg.getSeverity() == message.getSeverity()) {
                messageFound = true;        
            }
        }
        return messageFound;
    }
}
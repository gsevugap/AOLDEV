@IsTest
public with sharing class ContentTriggerHandletTest {
    
     @IsTest
     public static void createContent() {
     	List<Content__c> listOfContent = TestUtility.createContent(true);
     	for(Content__c  content: listOfContent){
     		content.Is_Free__c = true;
     	}
     	update listOfContent;
     	for(Content__c  content: listOfContent){
     		content.Is_Free__c = false;
     	  content.Subscription_Category__c = 'Journey (premium)';
		  content.Price__c = 8.0;	
     	}
     	update listOfContent;
     	for(Content__c  content: listOfContent){
     	  content.Is_Free__c = false;
     	  content.Subscription_Category__c = 'Journey (basic)';
		  content.Price__c = 9.0;	
     	}
     	update listOfContent;
    }   
    
    @IsTest
     public static void test() {
        List<Teacher_Master__c> listOfTeacherMaster = TestUtility.createTeacherMaster(true);
        List<Account> listPersonAccounts = TestUtility.createPersonAccounts(true);
        
     	List<Content__c> listOfContent = TestUtility.createContent(false);
     	for(Content__c  content: listOfContent){
     		content.Primary_Teacher_Master__c = listOfTeacherMaster[0].id;
     		content.Co_Teacher_M_1__c = listOfTeacherMaster[0].id;
     		content.Co_Teacher_M_2__c = listOfTeacherMaster[0].id;
     	}
     	insert listOfContent;
     	System.assertNotEquals(null, [SELECT Primary_Teacher__c FROM Content__c WHERE Id = :listOfContent[0].Id].Primary_Teacher__c);
     	for(Content__c  content: listOfContent){
     		content.Primary_Teacher_Master__c = listOfTeacherMaster[1].id;
     		content.Co_Teacher_M_1__c = listOfTeacherMaster[1].id;
     		content.Co_Teacher_M_2__c = listOfTeacherMaster[1].id;
     	}
     	update listOfContent;
     	System.assertNotEquals(null, [SELECT Primary_Teacher__c FROM Content__c WHERE Id = :listOfContent[0].Id].Primary_Teacher__c);
     	
     	for(Content__c  content: listOfContent){
            content.Primary_Teacher_Master__c = null;
            content.Co_Teacher_M_1__c = null;
            content.Co_Teacher_M_2__c = null;
     	}
     	update listOfContent;
     	System.assertEquals(null, [SELECT Primary_Teacher__c FROM Content__c WHERE Id = :listOfContent[0].Id].Primary_Teacher__c);
     	
    }   
    
}
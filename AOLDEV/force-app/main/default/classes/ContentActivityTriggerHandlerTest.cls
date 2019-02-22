@IsTest
public with sharing class ContentActivityTriggerHandlerTest {
    
    @IsTest
     public static void createContentActivity() {
     Test.startTest();
     	List<Account> listOfAccount = TestUtility.createPersonAccounts(true);
     	List<Content__c> listOfContent = TestUtility.createContent(true);
     	List<Content_Activity__c> listOfAttendee = TestUtility.createContentActivity(listOfContent, listOfAccount, true);
     	
     	Test.stopTest();
    }   
    
}
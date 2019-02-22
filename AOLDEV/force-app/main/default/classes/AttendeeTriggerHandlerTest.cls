@IsTest
public with sharing class AttendeeTriggerHandlerTest {
	
	@IsTest
     public static void createAttendee() {
     	Test.startTest();
     	List<Account> listOfAccount = TestUtility.createPersonAccounts(true);
     	List<Event__c> listOfEvent = TestUtility.createWorkshop(true);
     	List<Attendee__c> listOfAttendee = TestUtility.createAttendees(listOfAccount,listOfEvent, true);
     	update listOfAttendee;
     	Test.stopTest();
    }   
    
}
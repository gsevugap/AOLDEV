@IsTest
public with sharing class EventTriggerHandlerTest {
     @IsTest
     public static void createWorkshop() {
     	List<Event__c> lstOfEvents = TestUtility.createWorkshop(true);
     	for(Event__c e : lstOfEvents){
     		e.workshop_course_expense__c = 10;
     		e.workshop_course_fee__c = 10;
     	}
     	update lstOfEvents;
    }
}
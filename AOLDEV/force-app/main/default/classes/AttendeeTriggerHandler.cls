public class AttendeeTriggerHandler {
    public static void beforeUpdate( Map<Id, Attendee__c> mapOfNewAttendee, Map<Id, Attendee__c> mapOfOldAttendee){
 
        List<Account> listOfPesronAccount = new List<Account>();
        List<Id> listOf = new List<Id>();
        for(String key : mapOfOldAttendee.keyset()){
            Attendee__c newAttendee = mapOfNewAttendee.get(key);
            Attendee__c oldAttendee = mapOfOldAttendee.get(key);   
            if(newAttendee.Is_Mandatory_Type_workshop__c  && newAttendee.Attended__c == true && oldAttendee.Attended__c == false && !newAttendee.Is_Mandatory_Workshop_Attended_By_User__c){
                listOfPesronAccount.add(new Account(id = newAttendee.Attendee__c, Is_Mandatory_Workshop_Attended__c  = true));
            }
        }
        update listOfPesronAccount;
        
    }
    
}
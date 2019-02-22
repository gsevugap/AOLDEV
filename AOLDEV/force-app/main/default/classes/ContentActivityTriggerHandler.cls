public class ContentActivityTriggerHandler {
    
    public static void updateContentRollup(List<Content_Activity__c> listOfContentActivity){
        Set<Id> setOfContents = new Set<Id>();
        for(Content_Activity__c ca : listOfContentActivity){
            setOfContents.add(ca.Content__c);
        }
        List<AggregateResult> resList = [Select count(id) activities, Content__c from Content_Activity__c where Content__c =:setOfContents group by Content__c];    
        List<Content__c> listOfUpdateableContent = new List<Content__c>();     
        for(AggregateResult ar:resList ){
            Content__c ct = new Content__c(id = ar.get('Content__c').toString(), Total_Activities__c  = (Integer)ar.get('activities'));
            listOfUpdateableContent.add(ct);
        }
        update listOfUpdateableContent;	    
    }
}
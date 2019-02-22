public class QRCodeScannerExtension {

    private final Event__c eventObj;
    
    public OutputMessage messageObj { get; set;}

    public String attendeeId { get; set;}

    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public QRCodeScannerExtension(ApexPages.StandardController stdController) {
        this.eventObj = (Event__c)stdController.getRecord();
        messageObj = new OutputMessage('', 0);
    }

    public void markAttendance() {
        
        
        List<Attendee__c > listOfAttendee = [Select id, Attended__c, Attendee__r.name from Attendee__c  where ((External_Id__c  =: attendeeId AND External_Id__c != NULL) OR Attendee__r.External_Id__c =:attendeeId OR Attendee__c =:attendeeId) and Event__c =:eventObj.id];
        if(listOfAttendee.size() > 0 ){
            if(listOfAttendee[0].Attended__c){
                messageObj = new OutputMessage('Attendance for '+listOfAttendee[0].Attendee__r.name+' already marked successfully. Please give next QR code', 1);    
            } else {
            	Attendee__c at = new Attendee__c(id= listOfAttendee[0].id, Attended__c  = true, Date__c = date.today());
            	update at;
            	messageObj = new OutputMessage('Attendance for '+listOfAttendee[0].Attendee__r.name+' marked successfully', 1);    
            }
        }else{
            messageObj = new OutputMessage('No record found for this event and passed attendee Id', 2);
        }
        
    }
    
    public class OutputMessage {
        public String message {get;set;}
        public Integer type {get;set;}
        
        public OutputMessage(String message, Integer type) {
            this.message = message;
            this.type = type;
        }
    }
}
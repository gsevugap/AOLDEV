@isTest
private class QRCodeScannerExtensionTest {

	private static testMethod void test() {
	    List<Event__c> lstOfEvents = TestUtility.createWorkshop(true);
	    Account personAccount = new Account( External_Id__c ='test', FirstName= 'testFirstName', LastName = 'testLastName', personEmail = 'test@aol.com');
	    
	    insert personAccount;
	    
	    Attendee__c attendeeObj = new Attendee__c(Event__c = lstOfEvents[0].id, Attendee__c = personAccount.id);
	    
	    insert attendeeObj;
	    
	    PageReference aPage = Page.QRCodeScanner;
        aPage.getParameters().put('id', lstOfEvents[0].id);
        test.setCurrentPage(aPage);
 
        // Instantiate the standard controller
        Apexpages.StandardController sc = new Apexpages.standardController(lstOfEvents[0]);
 
        // Instantiate the extension
        QRCodeScannerExtension ext = new QRCodeScannerExtension(sc);
        ext.markAttendance();
        
        System.assertEquals('No record found for this event and passed attendee Id', ext.messageObj.message);
        
        ext.attendeeId = personAccount.id;
        
        ext.markAttendance();
        
        System.assertEquals('Attendance for testFirstName testLastName marked successfully', ext.messageObj.message);
        
        ext.markAttendance();
        
        System.assertEquals('Attendance for testFirstName testLastName already marked successfully. Please give next QR code', ext.messageObj.message);
	}
}
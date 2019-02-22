@IsTest
public class AccountTriggerHandlerTest {
    
    @IsTest
    public static void createTeachersAndPersonAccount(){
        List<Teacher_Master__c> listOfTeachers = TestUtility.createTeacherTemp(true);
        List<Account> listOfAccount = TestUtility.createPersonAccounts(true);
        
        
        System.assertNotEquals(listOfTeachers.size(), listOfAccount.size());
        
        for(Account accObj : listOfAccount) {
            accObj.Is_Email_Verified__c = true;
            accObj.Is_Active__c = true;
        }
        update listOfAccount;
        
        Student_Master__c sobj = new Student_Master__c(
          Name = '6795',                        // Student Id
          First_Name__c = 'Yvonne',               // First Name
          Last_Name__c = 'Perkins',               // Last Name
          Street_Address__c = '133 ellis drive',  // Street Address
          Birth_Date__c = '12/31/69',             // Birth Date
          City__c = 'Conyers',                    // City
          State__c = 'Georgia',                   // State
          Postal_Code__c = '30012',               // Postal Code
          Country__c = 'United States',           // Country
          Email__c = 'yvonnep52@yahoo.com',       // Email
          Home_Phone__c = '4047984000',           // Home Phone
          Mobile_Phone__c = '4047984000',         // Mobile Phone
          Teacher__c = 'Alice Holliday',          // Teacher
          HP_Taken__c = true,                     // HP Taken
          AOS_Taken__c = true,                    // AOS Taken
          AOS_Cnt__c = 1,                       // AOS Cnt
          Full_Name__c = 'Yvonne Perkins'        // Full Name
        );
        insert sobj;
        
        listOfAccount = new List<Account>();
        for(integer i=0; i<10; i++){
            listOfAccount.add( new Account( Entity_Type__pc = 'Teacher', External_Id__c ='stest'+i, FirstName= 'stestFirstName'+i, LastName = 'stestLastName'+i, personEmail = i+'stest@aol.com')); 
        }
        
        listOfAccount.add( new Account( Entity_Type__pc = 'Student', External_Id__c ='stest', FirstName= 'stestFirstName', LastName = 'stestLastName', personEmail = 'yvonnep52@yahoo.com'));
        
        insert listOfAccount;
        
        for(Account accObj : listOfAccount) {
            accObj.Is_Email_Verified__c = true;
            accObj.Is_Active__c = true;
        }
        update listOfAccount;
    }

}
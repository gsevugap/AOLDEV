public class AccountTriggerHandler{
    
    private static final String TEACHER_TYPE = 'Teacher';
    
    private static final String STUDENT_TYPE = 'Student';

    private static final String CC_PROFILE_NAME = 'Teacher';

    private static void replicateEmailInOtherField(List<Account> listOfAccounts) {
        for(Account acc : listOfAccounts) {
            acc.Person_Account_Email__c = acc.personEmail;      
        }
    }
    
    public static void handleBeforeInsert(List<Account> triggerNew){
        replicateEmailInOtherField(triggerNew);
        lookupTeachers(triggerNew);
        lookupStudents(triggerNew);
    }
    
    public static void handleBeforeUpdate(Map<Id,Account> triggerOldMap, Map<Id,Account> triggerNewMap) {
        replicateEmailInOtherField(triggerNewMap.values());
    }
    
    public static void handleAfterInsert(Map<Id,Account> triggerNewMap){
        //createTeachers(triggerNewMap);
    }
    
    public static void handleAfterUpdate(Map<Id,Account> triggerOldMap, Map<Id,Account> triggerNewMap) {
        Map<Id, Account> filteredNewMap = new Map<Id, Account>();
        for(Account accountObj : triggerNewMap.values()) {
            if(accountObj.Teacher_Master__c != null && accountObj.Is_Email_Verified__c && accountObj.Is_Active__c) {
                filteredNewMap.put(accountObj.Id, accountObj);
            }
        }
        for(User userObj : [SELECT Id, AccountId FROM User WHERE AccountId IN :filteredNewMap.keySet()]) {
            filteredNewMap.remove(userObj.AccountId);
        }
        System.debug('filteredNewMap = ' + filteredNewMap);
        if(filteredNewMap.size() > 0) {
            createTeachers(filteredNewMap);
        }
    }
    
    private static void lookupStudents(List<Account> triggerNew) {
        Map<String, Account> emailAccountMap = new Map<String, Account>();
        for(Account accountObj : triggerNew) {
            if(accountObj.Entity_Type__pc == STUDENT_TYPE) {
                emailAccountMap.put(accountObj.personEmail.toUpperCase(), accountObj);
            }
        }
        for(Student_Master__c tmpStudent : [Select Id, HP_Taken__c, AOS_Taken__c, AOS_Cnt__c, Key__c
                                            FROM Student_Master__c
                                            where Key__c in :emailAccountMap.keySet() ]) {
                                            
                                                if(emailAccountMap.containsKey(tmpStudent.Key__c)) {
                                                    Account acc = emailAccountMap.get(tmpStudent.Key__c);
                                                    
                                                    acc.Is_Mandatory_Workshop_Attended__c = tmpStudent.HP_Taken__c;
                                                    acc.AOS_Attended__c = tmpStudent.AOS_Taken__c;
                                                    acc.AOS_Attended_Count__c = tmpStudent.AOS_Cnt__c;
                                                }
                                            }
    }
    
    private static void lookupTeachers(List<Account> triggerNew) {
        Map<String, Account> idLookupKeyMap = new Map<String, Account>();

        for(Account acc : triggerNew){
            if( String.isNotBlank(acc.PersonEmail) &&  String.isNotBlank(acc.FirstName) && String.isNotBlank(acc.LastName) ) {
                idLookupKeyMap.put(acc.FirstName.toUpperCase() + '_' + acc.LastName.toUpperCase() + '_' + acc.PersonEmail.toUpperCase(), acc);
            }
        }
        System.debug(' ==== idLookupKeyMap === '+idLookupKeyMap);
        for(Teacher_Master__c tmpTchr : [Select Id, Teacher_Id__c, Lookup_Key__c, state__c, Postal_Code__c , City__c, Account_Type__c, Teacher_Code__c, Home_Phone__c, Mobile_Phone__c, Teacher_Type__c 
                                            FROM Teacher_Master__c
                                            where Lookup_Key__c in :idLookupKeyMap.keySet() ]) {
                                            
                                            Account acc = idLookupKeyMap.get(tmpTchr.Lookup_Key__c);
                                            System.debug(' ==== acc === '+acc);
                                            if (acc != null){
                                                acc.PersonMailingCity = tmpTchr.City__c;
                                                acc.PersonMailingState = tmpTchr.State__c;
                                                acc.PersonMailingPostalCode = tmpTchr.Postal_Code__c;
                                                acc.Entity_Type__pc = tmpTchr.Account_Type__c; 
                                                acc.Teacher_Code__c = tmpTchr.Teacher_Code__c;
                                                acc.PersonHomePhone = tmpTchr.Home_phone__c;
                                                acc.PersonMobilePhone = tmpTchr.Mobile_Phone__c;
                                                acc.Teacher_Id__c = tmpTchr.Teacher_Id__c;
                                                acc.Is_Mandatory_Workshop_Attended__c = true;
                                                acc.Type = tmpTchr.Teacher_Type__c;
                                                acc.Teacher_Master__c = tmpTchr.id;
                                            }
                                        }
    }
    
    private static string getNewUserEmail(string email) {
        String regex = '@(.*)';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(email);
        
        String username;
        String domain;
        
        if(regexMatcher.find()) {
           username = email.replaceAll(regex, '') + Math.Rint(Math.Random()*100);
           domain = regexMatcher.group();
        }
        
        return username + domain;
    }
    
    private static void createTeachers(Map<Id,Account> triggerNewMap){
        
        Id ccProfileId = [Select Id from Profile where Name = :CC_PROFILE_NAME  LIMIT 1].Id;
        Map<String, Id> usernamesAccIdMap = new Map<String, Id>();
        Map<Id,User> users = new Map<Id,User>();
        
        for (Account acc: triggerNewMap.values()) {
            if(acc.Entity_Type__pc == TEACHER_TYPE) {
                
                String usernameStr = acc.PersonEmail;
                System.debug('Username Generated = ' + usernameStr);
                String alias = acc.FirstName.substring(0,2) + acc.LastName.substring(0,2) +  (Math.Rint(Math.Random()*100));
                alias = alias.replaceAll('.0', '');
                
                usernameStr = usernamesAccIdMap.containsKey(usernameStr) ? getNewUserEmail(usernameStr).replaceAll('.0','') : usernameStr;
                
                usernamesAccIdMap.put(usernameStr, acc.Id); //accumulate users to check for uniqueness and add a digit if dupe found
                 
                User commUser = new User(FirstName = acc.FirstName, 
                                         LastName = acc.LastName, 
                                         Email = acc.PersonEmail, 
                                         Teacher_Code__c = acc.Teacher_Code__c,
                                         Username= userNameStr, Alias=alias,
                                         ProfileId = ccProfileId, 
                                         CommunityNickName = alias,
                                         EmailEncodingKey = 'ISO-8859-1', 
                                         LanguageLocaleKey = 'en_US', 
                                         LocaleSidKey = 'en_US', 
                                         TimeZoneSidKey = 'America/New_York',  
                                         ContactId = acc.PersonContactId);
                 
                 users.put(acc.Id, commUser);   
            }
        }
        
        //search the db to see if the generated username collides with an existing username
        for(User dupeUser : [Select Id, Username from User where Username IN :usernamesAccIdMap.keySet() AND IsActive=true]){
            
            Account accVar = (Account)trigger.newMap.get(usernamesAccIdMap.get(dupeUser.userName));
            users.get(accVar.Id).Username = getNewUserEmail(dupeUser.userName).replaceAll('.0','');
                
        }
        System.debug('Before Username = ' + users);
        database.Insert(users.values(), false);
        System.debug('After Username = ' + users);
    }
}
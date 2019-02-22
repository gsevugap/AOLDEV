/* created by Agastheswar Suribhatla

This batch class is used to share the Person Account records with Public groups */

public class sharePAccountRecordsWithPublicGroups implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT ID, Name, Entity_Type__pc,  PersonMailingState, PersonMailingCountry From Account');
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope){
        
        List<group> publicGroups = [Select Id,DeveloperName from Group where Type='Regular'];
        List< AccountShare > accountShares = new List< AccountShare >();
        List<State_Codes__mdt> stateCodes = [select state_codes__c, State_Name__c from State_Codes__mdt];
        Map<String, String> stateCodeMap = new Map<String, String>();
        for(State_Codes__mdt state : stateCodes){
            String stateName = state.State_Name__c;            
            stateCodeMap.put(stateName.toLowerCase(), state.state_codes__c);
        }
        System.debug(stateCodeMap + '!!!');
        
        for(Account account: scope){
            String mailingState = account.PersonMailingState;
            String groupName = stateCodeMap.get(mailingState.toLowerCase()) + '_US_COORDINATORS';
            for(group pGroup: publicGroups){
                if( pGroup.DeveloperName== groupName){

                    AccountShare accountShare = new AccountShare();
                    accountShare.AccountId = account.Id;
                    accountShare.UserOrGroupId = pGroup.Id;
                    accountShare.AccountAccessLevel = 'Edit';
                    accountShare.CaseAccessLevel = 'Read';
                    accountShare.OpportunityAccessLevel = 'Read';
                    accountShares.add(accountShare);

                }
            }
        }
        List<Database.UpsertResult> sr = Database.upsert(accountShares,false);

    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('Person Account Job has finished');
    }
}
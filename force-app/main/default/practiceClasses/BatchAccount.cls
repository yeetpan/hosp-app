public with sharing class BatchAccount implements Database.Batchable <sObject> {
    public static Database.QueryLocator start(Database.BatchableContext bc){
        List<Account> accounts=[SELECT Id,Name FROM Account];
        return Database.getQueryLocator(accounts);
    } 
    
    public static void execute(Database.BatchableContext bc, List<Account> scope){
        List<Contact> relatedContacts=new List<Contact>();
        for(Account acc:scope){
            Contact con=new Contact();
            con.LastName=acc.Name;
            con.AccountId=acc.Id;
            relatedContacts.add(con);
        }
        Database.SaveResult[]results=Database.insert(relatedContacts,false);
        for(Database.SaveResult sr:results){
            if(!sr.isSuccess()){
                System.debug('Contact could not be created');
            }
        }    
    }

    public static void finish(Database.BatchableContext bc){
        System.debug('Batch has been completed.');
    }
}
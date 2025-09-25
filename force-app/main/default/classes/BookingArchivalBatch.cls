public with sharing class BookingArchivalBatch implements Database.Batchable <sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query='SELECT Id,Name,Booking_Status__c,Is_Archived__c FROM Booking__c WHERE Booking_Status__c = \'Cancelled\' AND CreatedDate < LAST_N_DAYS:7 AND Is_Archived__c=\'false\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Booking__c> scope){
        for(Booking__c b:scope){
            b.Is_Archived__c=true;
        }
        Database.update(scope);
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Batch completed');
    }
}
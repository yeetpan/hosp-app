global with sharing class FoodOrderArchivalBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query='SELECT Id,Name,Status__c,Is_Archived__c FROM Food_Order__c WHERE Status__c = \'Cancelled\' AND Is_Archived__c=\'false\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Food_Order__c> scope){
        for(Food_Order__c f:scope){
            f.Is_Archived__c=true;
        }
    
        Database.update(scope);
}

    global void finish(Database.BatchableContext bc){
        System.debug('Batch completed');
    }
}
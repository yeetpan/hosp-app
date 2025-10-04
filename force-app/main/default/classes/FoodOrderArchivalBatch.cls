global  class FoodOrderArchivalBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        //querying for cancelled orders which are not archived yet.
        String query='SELECT Id,Name,Status__c,Is_Archived__c FROM Food_Order__c WHERE Status__c = \'Cancelled\' AND Is_Archived__c=false';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Food_Order__c> scope){
        //scope null checks to avoid DML exceptions.
        if(scope.isEmpty()){
            return;
        }
        //mark archive as true.
        for(Food_Order__c f:scope){
            f.Is_Archived__c=true;
        }
        // update database scope.
        Database.update(scope);
}

    global void finish(Database.BatchableContext bc){
        System.debug('Batch completed');
    }
}
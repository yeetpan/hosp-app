global with sharing class FoodOrderQueueArchival implements Queueable{
    global void execute(QueueableContext sc){
        Database.executeBatch(new FoodOrderArchivalBatch(),200);
    } 
}
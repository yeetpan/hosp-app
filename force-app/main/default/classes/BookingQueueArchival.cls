global with sharing class BookingQueueArchival implements Queueable {
    global void execute(QueueableContext sc){
        Database.executeBatch(new BookingArchivalBatch(),200);
    }
}
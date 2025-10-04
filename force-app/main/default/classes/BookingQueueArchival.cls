global class BookingQueueArchival implements Queueable {
    global void execute(QueueableContext sc) {
        Database.executeBatch(new BookingArchivalBatch(), 200);
        //on success of the batch class then queue the next batch class using queueable.
        System.enqueueJob(new FoodOrderQueueArchival());
    }
}
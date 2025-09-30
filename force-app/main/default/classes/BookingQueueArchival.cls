global class BookingQueueArchival implements Queueable {
    global void execute(QueueableContext sc) {
        Database.executeBatch(new BookingArchivalBatch(), 200);
        // Chain the next queueable
        System.enqueueJob(new FoodOrderQueueArchival());
    }
}
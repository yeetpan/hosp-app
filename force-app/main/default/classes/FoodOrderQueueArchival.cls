global class FoodOrderQueueArchival implements Queueable {
    global void execute(QueueableContext sc) {
        //database execute batch method is used to execute the batch class.
        Database.executeBatch(new FoodOrderArchivalBatch(), 200);
    }
}

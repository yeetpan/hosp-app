global class weeklyArchival implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new BookingQueueArchival());
    }
}

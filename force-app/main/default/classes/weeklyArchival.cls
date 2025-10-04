global class weeklyArchival implements Schedulable {
    // this schedulable class is used to archive the bookings and food orders which are cancelled in the last week.
    global void execute(SchedulableContext sc) {
        //enqueue booking job first.
        System.enqueueJob(new BookingQueueArchival());
    }
}

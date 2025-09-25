global  class WeeklyArchival implements Schedulable{
    global void execute(SchedulableContext sc){
        System.enqueueJob(new BookingQueueArchival(),200);

        System.enqueueJob(new FoodOrderQueueArchival(),200);
    } 
}
trigger BookingTrigger on Booking__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        BookingTriggerHandler.handleAfterUpdate(Trigger.new,Trigger.oldMap);
    }
}
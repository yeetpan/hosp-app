public  without sharing class BookingTriggerHandler {
    public static void handleAfterUpdate(List<Booking__c> newBookings,Map<Id,Booking__c> oldBookingsMap){
        if(newBookings.isEmpty()) return;
        Id gmProfileId=[SELECT Id FROM Profile WHERE Name='General_Manager' LIMIT 1].Id;
        // only one user but still took list as part of best practices.
        List<User>gmUsers=[SELECT Id,Email,Name,ContactId FROM User WHERE ProfileId=:gmProfileId AND IsActive=true];
        // as of now only one general manager is present so no bulkification done.
        List<Task>newTasks=new List<Task>();    
        for(Booking__c book:newBookings){
            if(oldBookingsMap.get(book.id).Booking_Status__c!='Cancelled' && book.Booking_Status__c=='Cancelled' && book.Guestt__c!=null){
                Task newTask=new Task();
                newTask.WhatId=book.Id;
                newTask.Subject='Investigate Booking Cancelled for '+book.Name;              
                newTask.WhoId=book.Guestt__c;
                newTask.Status='Not Started';
                newTask.OwnerId=gmUsers[0].Id;
                newTask.ActivityDate=System.today().addDays(7);
                newTasks.add(newTask);
            }
        }
        if(!newTasks.isEmpty()){
            Database.insert(newTasks);
        }
    }
}
@isTest
public class BookingTriggerHandlerTest {

    @testSetup
    static void setupData() {
        // Create Contact (guest)
        Contact guest = new Contact(
            FirstName = 'Test',
            LastName = 'Guest',
            Email = 'guest@test.com'
        );
        insert guest;

        // Create Booking not Cancelled initially
        Booking__c booking = new Booking__c(
            Guestt__c = guest.Id,
            Booking_Status__c = 'Confirmed'
        );
        insert booking;
    }

    @isTest
    static void testTaskCreatedOnBookingCancelled() {
        // Get booking created in testSetup
        Booking__c book = [SELECT Id, Booking_Status__c FROM Booking__c LIMIT 1];

        Test.startTest();
        // Update booking status to Cancelled → should trigger handler
        book.Booking_Status__c = 'Cancelled';
        update book;
        Test.stopTest();

        // Assert task got created
        List<Task> tasks = [
            SELECT Id, WhatId, WhoId, OwnerId, Subject, Status 
            FROM Task WHERE WhatId = :book.Id
        ];

        System.assertEquals(1, tasks.size(), 'One Task should be created');
        System.assertEquals('Not Started', tasks[0].Status, 'Task status should be Not Started');
        System.assert(tasks[0].Subject.contains('Investigate Booking Cancelled'), 'Task subject should mention cancelled booking');
    }

    @isTest
    static void testNoTaskIfAlreadyCancelled() {
        // First cancel a booking
        Booking__c book = [SELECT Id, Booking_Status__c FROM Booking__c LIMIT 1];
        book.Booking_Status__c = 'Cancelled';
        update book;

        Test.startTest();
        // Try updating again (should not create duplicate tasks)
        update book;
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :book.Id];
        System.assertEquals(1, tasks.size(), 'No extra tasks should be created on repeated Cancelled update');
    }
}

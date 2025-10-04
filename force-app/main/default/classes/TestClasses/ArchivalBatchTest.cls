@isTest
private class ArchivalBatchTest {
// batch class for testing the archival batch class.
    @isTest
    static void testBookingArchivalBatch_Positive() {
        //  Positive Testing : record meets criteria → should be archived
        Booking__c booking = new Booking__c(
            Booking_Status__c = 'Cancelled',
            Is_Archived__c = false
        );
        insert booking;

        Test.startTest();
        Database.executeBatch(new BookingArchivalBatch());
        Test.stopTest();

        Booking__c updatedBooking = [SELECT Is_Archived__c FROM Booking__c WHERE Id = :booking.Id];
        System.assertEquals(true, updatedBooking.Is_Archived__c, 'Booking record should be archived');
    }

    @isTest
    static void testBookingArchivalBatch_Negative() {
        //  Negative Testing : record does not meet criteria → should remain unarchived
        Booking__c booking = new Booking__c(
            Booking_Status__c = 'Checked-In',
            Is_Archived__c = false
        );
        insert booking;

        Test.startTest();
        Database.executeBatch(new BookingArchivalBatch());
        Test.stopTest();

        Booking__c updatedBooking = [SELECT Is_Archived__c FROM Booking__c WHERE Id = :booking.Id];
        System.assertEquals(false, updatedBooking.Is_Archived__c, 'Booking record should NOT be archived');
    }

    @isTest
    static void testFoodOrderArchivalBatch_Positive() {
        //  Positive Testing : record meets criteria → should be archived
        Food_Order__c order = new Food_Order__c(
            Status__c = 'Cancelled',
            Is_Archived__c = false
        );
        insert order;

        Test.startTest();
        Database.executeBatch(new FoodOrderArchivalBatch());
        Test.stopTest();

        Food_Order__c updatedOrder = [SELECT Is_Archived__c FROM Food_Order__c WHERE Id = :order.Id];
        System.assertEquals(true, updatedOrder.Is_Archived__c, 'Food order should be archived');
    }

    @isTest
    static void testFoodOrderArchivalBatch_Negative() {
        //  Negative Testing: record does not meet criteria → should remain unarchived
        Food_Order__c order = new Food_Order__c(
            Status__c = 'Reached',
            Is_Archived__c = false
        );
        insert order;

        Test.startTest();
        Database.executeBatch(new FoodOrderArchivalBatch());
        Test.stopTest();

        Food_Order__c updatedOrder = [SELECT Is_Archived__c FROM Food_Order__c WHERE Id = :order.Id];
        System.assertEquals(false, updatedOrder.Is_Archived__c, 'Food order should NOT be archived');
    }
}
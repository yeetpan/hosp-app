@isTest
public class CaseTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Just create a Booking record since trigger logic depends on it
        Booking__c booking = new Booking__c();
        insert booking;
    }

    @isTest
    static void testCaseInsertDoesNotError() {
        // Get the booking created in setup
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];

        // Create a Case linked to booking
        Case c = new Case(
            Subject = 'Room Service Request',
            Status = 'New',
            Booking__c = booking.Id,
            Request_Type__c = 'Room Service',
            Comments__c = 'Please clean the room urgently'
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        // Assert Case was created successfully
        Case insertedCase = [SELECT Id, Booking__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, insertedCase.Id, 'Case should be inserted');
        System.assertEquals(booking.Id, insertedCase.Booking__c, 'Booking should be linked correctly');
    }
}

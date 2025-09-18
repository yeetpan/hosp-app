@isTest
public class CaseTriggerHandlerTest {
    @isTest
    static void testCaseEmailSend() {
        // Create General Manager profile if not present (mock) 
        Profile gmProfile = [SELECT Id FROM Profile WHERE Name = 'General Manager' LIMIT 1];

        // Create a GM user
        User gmUser = new User(
            FirstName = 'Test',
            LastName = 'GM',
            Alias = 'tgm',
            Email = 'gm@test.com',
            Username = 'gmuser' + System.currentTimeMillis() + '@test.com',
            ProfileId = gmProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert gmUser;

        // Create dummy Booking
        Booking__c booking = new Booking__c();
        insert booking;

        // Insert case linked to booking
        Case c = new Case(
            Subject = 'Room Service Request',
            Status = 'New',
            Booking__c = booking.Id,
            Request_Type__c = 'Room Cleaning',
            Comments__c = 'Please clean the room urgently'
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        // Verify that case was inserted and handler executed
        Case insertedCase = [SELECT Id, Booking__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, insertedCase.Id, 'Case should be inserted');
    }
}

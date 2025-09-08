@isTest
private class UserUtilsTest {
    @isTest static void testGetSessionContactId() {
        User u = new User(
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            LastName = 'Tester',
            Email = 'testuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        Test.startTest();
        System.runAs(u) {
            Id cId = UserUtils.getSessionContactId();
            System.assertEquals(null, cId, 'Internal user should return null ContactId');
        }
        Test.stopTest();
    }
}

public with sharing class CaseTriggerHandler {
    public static void handleAfterInsert(List<Case> newCases) {
        // Collect booking-related cases
        List<Case> bookingCases = new List<Case>();
        for (Case c : newCases) {
            if (c.Booking__c != null) { // only if linked to booking
                bookingCases.add(c);
            }
        }

        if (bookingCases.isEmpty()) return;

        // Get General Manager profile Id
        Id gmProfileId = [SELECT Id FROM Profile WHERE Name = 'General_Manager' LIMIT 1].Id;

        // Get users with GM profile
        List<User> gmUsers = [SELECT Id, Email FROM User WHERE ProfileId = :gmProfileId AND IsActive = true];

        if (gmUsers.isEmpty()) return;

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Case c : bookingCases) {
            for (User gm : gmUsers) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ gm.Email });
                email.setSubject('New Service Request for Booking: ' + c.Booking__c);
                email.setPlainTextBody(
                    'Hello ' +gm.Name+ '\n\n' +
                    'A new Service Request has been created for a booking.' + '\n\n' +
                    'Request Type: ' + c.Request_Type__c + '\n' +
                    'Comments: ' + c.Comments__c + '\n\n' +
                    'Case Id: ' + c.Id + '\n\n' +
                    'Regards,\nHospitality App'
                );
                emails.add(email);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}

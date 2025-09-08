public with sharing class CaseController {
  /**
   * Return confirmed or checked-in bookings for current user's contact.
   */
  @AuraEnabled(cacheable=true)
  public static List<Booking__c> getConfirmedBookings() {
    Id contactId = UserUtils.getSessionContactId();
    if (contactId == null) {
      // Return empty list instead of throwing an exception.
      return new List<Booking__c>();
    }

    return [
      SELECT
        Id,
        Name,
        Booking_Status__c,
        Check_In_Date__c,
        Check_Out_Date__c,
        Number_Of_Guests__c,
        Total_Amount__c,
        Room__c,
        Room__r.Name,
        Room__r.Room_Type__c,
        Room__r.Price_Per_Night__c
      FROM Booking__c
      WHERE
        Guestt__c = :contactId
        AND Booking_Status__c IN ('Confirmed', 'Checked-In')
      ORDER BY Check_In_Date__c ASC
    ];
  }

  /**
   * Return single Booking with parent Room fields for pre-filling the service request form.
   */
  @AuraEnabled(cacheable=true)
  public static Booking__c getBookingById(Id bookingId) {
    if (bookingId == null) {
      return null;
    }
    return [
      SELECT
        Id,
        Name,
        Booking_Status__c,
        Check_In_Date__c,
        Check_Out_Date__c,
        Number_Of_Guests__c,
        Total_Amount__c,
        Room__c,
        Room__r.Name,
        Room__r.Room_Type__c,
        Room__r.Price_Per_Night__c
      FROM Booking__c
      WHERE Id = :bookingId
      LIMIT 1
    ];
  }

  // Create a Case (Service Request) linked to the hotel's Account and user's Contact.
  @AuraEnabled
  public static Id createServiceRequest(
    String subject,
    String comments,
    Id bookingId,
    String requestType
  ) {
    Id contactId = UserUtils.getSessionContactId();
    if (contactId == null) {
      throw new AuraHandledException('No Contact found for current user.');
    }

    Case newCase = new Case(
      Subject = subject,
      Comments__c = comments,
      ContactId = contactId,
      AccountId = '001gL00000H1UdNQAV', // Hotel Taj account
      Origin = 'Community',
      Status = 'Working',
      Request_Type__c = requestType, // Service Request
      Booking__c = bookingId
    );

    insert newCase;
    return newCase.Id;
  }

  @AuraEnabled(cacheable=true)
  public static List<Case> getCases() {
    Id contactId = UserUtils.getSessionContactId();
    if (contactId == null) {
      throw new AuraHandledException('No Contact found for current user.');
    }
    return [
      SELECT Id,Subject,CaseNumber, Request_Type__c, CreatedDate, Comments__c,Status
      FROM Case
      WHERE ContactId = :contactId
      ORDER BY CreatedDate DESC
    ];
  }
}

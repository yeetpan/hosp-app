public with sharing class BookingController {

    @AuraEnabled(cacheable=true)
    public static List<Room__c> getAvailableRooms(String roomType) {
        return [
            SELECT Id, Name, Room_Type__c, Status__c,Price_Per_Night__c
            FROM Room__c
            WHERE Status__c = 'Available' AND Room_Type__c = :roomType
        ];
    }

    @AuraEnabled
    public static Booking__c createBooking(Date checkIn, Date checkOut, Integer noOfGuests, Id roomId,Decimal totalAmount ) {
        Id contactId = UserUtils.getSessionContactId();
        
        //  Create Booking Record
        Booking__c booking = new Booking__c(
            Guestt__c = contactId,
            Check_In_Date__c = checkIn,
            Check_Out_Date__c = checkOut,
            Number_Of_Guests__c = noOfGuests,
            Room__c = roomId,
            Booking_Status__c = 'Confirmed',
            Total_Amount__c=totalAmount
        );
        insert booking;

        // Step 2: Update Room Status → Booked
        updateRoomStatus(roomId, 'Booked');

        return booking;
    }

    private static void updateRoomStatus(Id roomId, String newStatus) {
        Room__c r = new Room__c(Id = roomId, Status__c = newStatus);
        update r;
    }

    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getUserBookings() {
        Id contactId = UserUtils.getSessionContactId();
        if (contactId == null) {
            throw new AuraHandledException('No Contact found for current user.');
        }

        return [
            SELECT Id, Name, Booking_Status__c, Check_In_Date__c, Check_Out_Date__c,
                   Number_Of_Guests__c, Room__r.Name, Room__r.Room_Type__c, Total_Amount__c
            FROM Booking__c
            WHERE Guestt__c = :contactId
            ORDER BY CreatedDate DESC
        ];
    }
    
    @AuraEnabled(cacheable=true)
public static Booking__c getBookingById(Id bookingId) {
    return [
        SELECT Id, Name, Booking_Status__c, Check_In_Date__c, Check_Out_Date__c,
               Number_Of_Guests__c, Total_Amount__c,
               Room__r.Name, Room__r.Room_Type__c, Room__r.Price_Per_Night__c
        FROM Booking__c
        WHERE Id = :bookingId
        LIMIT 1
    ];
}
 @AuraEnabled
    public static void cancelBooking(Id bookingId) {
        Booking__c b = [
            SELECT Id, Booking_Status__c, Room__c
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
        b.Booking_Status__c = 'Cancelled';
        update b;

        // free the room back
        if (b.Room__c != null) {
            Room__c r = [SELECT Id, Status__c FROM Room__c WHERE Id = :b.Room__c LIMIT 1];
            r.Status__c = 'Available';
            update r;
        }
    }
}

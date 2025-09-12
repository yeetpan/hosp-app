public with sharing class DashboardController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getDashboardStats() {
        Id currentUserId = UserInfo.getUserId();
        Map<String, Integer> stats = new Map<String, Integer>();

        // ---------------- FOOD ORDERS ----------------
        stats.put('TotalOrders', [
            SELECT COUNT() 
            FROM Food_Order__c 
            WHERE CreatedById = :currentUserId
        ]);

        stats.put('ActiveOrders', [
            SELECT COUNT() 
            FROM Food_Order__c 
            WHERE CreatedById = :currentUserId 
            AND Status__c IN ('Ordered','Preparing','Reached')
        ]);

        stats.put('CompletedOrders', [
            SELECT COUNT() 
            FROM Food_Order__c 
            WHERE CreatedById = :currentUserId 
            AND Status__c = 'Completed'
        ]);

        stats.put('CancelledOrders', [
            SELECT COUNT() 
            FROM Food_Order__c 
            WHERE CreatedById = :currentUserId 
            AND Status__c = 'Cancelled'
        ]);

        // ---------------- BOOKINGS ----------------
        stats.put('TotalBookings', [
            SELECT COUNT() 
            FROM Booking__c 
            WHERE CreatedById = :currentUserId
        ]);

        stats.put('ActiveBookings', [
            SELECT COUNT() 
            FROM Booking__c 
            WHERE CreatedById = :currentUserId
            AND Booking_Status__c IN ('Confirmed','Checked-In')
        ]);

        stats.put('CompletedBookings', [
            SELECT COUNT() 
            FROM Booking__c 
            WHERE CreatedById = :currentUserId
            AND Booking_Status__c = 'Checked-Out'
        ]);

        // ---------------- SERVICE REQUESTS ----------------
        stats.put('TotalRequests', [
            SELECT COUNT() 
            FROM Case 
            WHERE CreatedById = :currentUserId
        ]);

        stats.put('OpenRequests', [
            SELECT COUNT() 
            FROM Case 
            WHERE CreatedById = :currentUserId
            AND Status = 'Open'
        ]);

        stats.put('ClosedRequests', [
            SELECT COUNT() 
            FROM Case 
            WHERE CreatedById = :currentUserId
            AND Status = 'Closed'
        ]);

        return stats;
    }
}

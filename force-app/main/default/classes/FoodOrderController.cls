public with sharing class FoodOrderController {

    // 1. Get Active Bookings for current user
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getActiveBookings() {
        Id contactId = UserUtils.getSessionContactId();
        return [
            SELECT Id, Name, Room__c, Room__r.Name
            FROM Booking__c
            WHERE Guestt__c = :contactId
            AND Booking_Status__c = 'Checked-In'
        ];
    }

    // 2. Get all available food items (menu)
    @AuraEnabled(cacheable=true)
    public static List<Food_Item__c> getFoodItems() {
        return [
            SELECT Id, Name, Price__c
            FROM Food_Item__c
        ];
    }

    // 3. Place a new food order with multiple items
    @AuraEnabled
    public static Id placeFoodOrder(Id bookingId, String specialNotes, List<FoodOrderItemWrapper> items) {
        if (items == null || items.isEmpty()) {
            throw new AuraHandledException('No food items selected.');
        }

        // Create the Food Order record
        Food_Order__c order = new Food_Order__c();
        order.Booking__c = bookingId;
        order.Status__c = 'Ordered';
        order.Special_Notes__c = specialNotes;
        insert order;

        List<Food_Order_Item__c> orderItems = new List<Food_Order_Item__c>();
        Decimal totalAmount = 0;

        for (FoodOrderItemWrapper wrap : items) {
            Food_Item__c fi = [SELECT Id, Price__c FROM Food_Item__c WHERE Id = :wrap.foodItemId LIMIT 1];
            Decimal lineTotal = fi.Price__c * wrap.quantity;

            orderItems.add(new Food_Order_Item__c(
                Food_Order__c = order.Id,
                Food_Item__c = wrap.foodItemId,
                Quantity__c = wrap.quantity,
                Line_Total__c = lineTotal
            ));

            totalAmount += lineTotal;
        }

        insert orderItems;

        // Update total on order
        order.Total_Amount__c = totalAmount;
        update order;

        return order.Id;
    }

    // 4. Get Active Orders (Ordered, Preparing, Reached)
    @AuraEnabled(cacheable=true)
    public static List<Food_Order__c> getActiveOrders() {
        return [
            SELECT Id, Name, Status__c, Special_Notes__c, Total_Amount__c,
                   Booking__r.Room__r.Name,
                   (SELECT Id, Food_Item__r.Name, Quantity__c, Line_Total__c
                    FROM Food_Order_Items__r)
            FROM Food_Order__c
            WHERE Status__c IN ('Ordered', 'Preparing', 'Reached')
            ORDER BY CreatedDate DESC
        ];
    }

    // 5. Get Order History (Cancelled or Completed)
    @AuraEnabled(cacheable=true)
    public static List<Food_Order__c> getOrderHistory() {
        return [
            SELECT Id, Name, Status__c, Special_Notes__c, Total_Amount__c,
                   Booking__r.Room__r.Name,
                   (SELECT Id, Food_Item__r.Name, Quantity__c, Line_Total__c
                    FROM Food_Order_Items__r)
            FROM Food_Order__c
            WHERE Status__c IN ('Cancelled', 'Completed')
            ORDER BY CreatedDate DESC
        ];
    }

    // 6. Cancel an Order
    @AuraEnabled
    public static void cancelOrder(Id orderId) {
        Food_Order__c order = [SELECT Id, Status__c FROM Food_Order__c WHERE Id = :orderId LIMIT 1];
        if (order.Status__c == 'Cancelled') {
            throw new AuraHandledException('Order already cancelled.');
        }
        order.Status__c = 'Cancelled';
        update order;
    }

    // Wrapper class for food order items
    public class FoodOrderItemWrapper {
        @AuraEnabled public Id foodItemId { get; set; }
        @AuraEnabled public Integer quantity { get; set; }
    }
}

public with sharing class FoodOrderController {

    // 1. get bookings for user to order food on specific room.
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

    // 2. get the menu to order food.
    @AuraEnabled(cacheable=true)
    public static List<Food_Item__c> getFoodItems() {
        return [
            SELECT Id, Name, Price__c
            FROM Food_Item__c
        ];
    }

    // 3. Place a new food order 
    @AuraEnabled
    public static Id placeFoodOrder(Id bookingId, String specialNotes, List<FoodOrderItemWrapper> items) {
    // null-check
    if (items == null || items.isEmpty()) {
        throw new AuraHandledException('No food items selected.');
    }

    //create new food order record.
    Food_Order__c order = new Food_Order__c(
        Booking__c = bookingId,
        Status__c = 'Ordered',
        Special_Notes__c = specialNotes
    );
    insert order;

    // store ids in the set to avoid redundancy as one can book multiple of the same food item.
    Set<Id> foodItemIds = new Set<Id>();
    for (FoodOrderItemWrapper wrap : items) {
        foodItemIds.add(wrap.foodItemId);
    }

    // store food items in the map to avoid multiple queries.
    Map<Id, Food_Item__c> foodItemMap = new Map<Id, Food_Item__c>(
        [SELECT Id, Price__c FROM Food_Item__c WHERE Id IN :foodItemIds]
    );

    // now create list to insert via DML.
    List<Food_Order_Item__c> orderItems = new List<Food_Order_Item__c>();
    Decimal totalAmount = 0;

    for (FoodOrderItemWrapper wrap : items) {
        Food_Item__c fi = foodItemMap.get(wrap.foodItemId);
        if (fi == null) {
            throw new AuraHandledException('Invalid Food Item selected.');
        }

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
            WHERE Status__c IN ('Ordered', 'Preparing')
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
            WHERE Status__c IN ('Cancelled', 'Reached')
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

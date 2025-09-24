import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getActiveBookings from '@salesforce/apex/FoodOrderController.getActiveBookings';
import getFoodItems from '@salesforce/apex/FoodOrderController.getFoodItems';
import placeFoodOrder from '@salesforce/apex/FoodOrderController.placeFoodOrder';
import getActiveOrders from '@salesforce/apex/FoodOrderController.getActiveOrders';
import getOrderHistory from '@salesforce/apex/FoodOrderController.getOrderHistory';
import cancelOrder from '@salesforce/apex/FoodOrderController.cancelOrder';

export default class FoodOrder extends LightningElement {
    selectedBooking;
    @track bookingOptions = [];
    specialNotes = '';
    @track foodItems = [];
    @track draftValues = [];
    @track activeOrders = [];
    @track orderHistory = [];

    wiredActiveOrdersResult;
    wiredHistoryResult;

    columns = [
        { label: 'Item Name', fieldName: 'Name', type: 'text' },
        { label: 'Price', fieldName: 'Price__c', type: 'currency' },
        { label: 'Quantity', fieldName: 'Quantity__c', type: 'number', editable: true }
    ];

    // --- Fetch Active Bookings ---
    @wire(getActiveBookings)
    wiredBookings({ data, error }) {
        if (data) {
            this.bookingOptions = data.map(b => ({
                label: b.Room__r.Name,
                value: b.Id
            }));
        } else if (error) {
            console.error(error);
        }
    }

    // --- Fetch Food Items ---
    @wire(getFoodItems)
    wiredFoodItems({ data, error }) {
        if (data) {
            this.foodItems = data.map(f => ({
                Id: f.Id,
                Name: f.Name,
                Price__c: f.Price__c,
                Quantity__c: 0
            }));
        } else if (error) {
            console.error(error);
        }
    }

    // --- Fetch Active Orders ---
    @wire(getActiveOrders)
    wiredActiveOrders(result) {
        this.wiredActiveOrdersResult = result;
        if (result.data) {
            this.activeOrders = result.data.filter(
                o => o.Status__c === 'Ordered' || o.Status__c === 'In Progress'
            );
        } else if (result.error) {
            console.error(result.error);
        }
    }

    // --- Fetch Order History ---
    @wire(getOrderHistory)
    wiredHistory(result) {
        this.wiredHistoryResult = result;
        if (result.data) {
            this.orderHistory = result.data.filter(
                o => o.Status__c === 'Cancelled' || 
                     o.Status__c === 'Completed' || 
                     o.Status__c === 'Reached'
            );
        } else if (result.error) {
            console.error(result.error);
        }
    }

    // Booking change
    handleBookingChange(event) {
        this.selectedBooking = event.detail.value;
    }

    // Notes change
    handleNotesChange(event) {
        this.specialNotes = event.detail.value;
    }

    // Quantity update
    handleSave(event) {
        const updates = event.detail.draftValues;
        updates.forEach(u => {
            let row = this.foodItems.find(r => r.Id === u.Id);
            if (row) {
                row.Quantity__c = u.Quantity__c;
            }
        });
        this.draftValues = [];
        this.foodItems = [...this.foodItems];
    }

    // Place order
    async handlePlaceOrder() {
        const orderedItems = this.foodItems
            .filter(i => i.Quantity__c > 0)
            .map(i => ({ foodItemId: i.Id, quantity: i.Quantity__c }));

        if (!this.selectedBooking) {
            this.showToast('Error', 'Please select a booking', 'error');
            return;
        }
        if (orderedItems.length === 0) {
            this.showToast('Error', 'Please select at least 1 item', 'error');
            return;
        }

        try {
            await placeFoodOrder({ 
                bookingId: this.selectedBooking, 
                specialNotes: this.specialNotes, 
                items: orderedItems 
            });
            this.showToast('Success', 'Order placed successfully!', 'success');

            await refreshApex(this.wiredActiveOrdersResult);
            await refreshApex(this.wiredHistoryResult);

            this.resetForm();
            

        } catch (err) {
            console.error(err);
            this.showToast('Error', err.body.message, 'error');
        }
    }

    // Cancel order
    async handleCancel(event) {
        const orderId = event.target.dataset.id;
        try {
            await cancelOrder({ orderId });
            this.showToast('Success', 'Order cancelled.', 'success');

            // 🔄 refresh both lists
            await refreshApex(this.wiredActiveOrdersResult);
            await refreshApex(this.wiredHistoryResult);

        } catch (err) {
            console.error(err);
            this.showToast('Error', err.body.message, 'error');
        }
    }

    // Reset form
    resetForm() {
        this.selectedBooking = null;
        this.specialNotes = '';
        this.foodItems = this.foodItems.map(f => ({ ...f, Quantity__c: 0 }));
    }

    // Tab change → refresh respective data
    async handleTabChange(event) {
        const tabValue = event.target.value;
        if (tabValue === 'activeOrders') {
            await refreshApex(this.wiredActiveOrdersResult);
        }
        if (tabValue === 'history') {
            await refreshApex(this.wiredHistoryResult);
        }
    }

    // Toast helper
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}

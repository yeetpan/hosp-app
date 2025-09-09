import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActiveBookings from '@salesforce/apex/FoodOrderController.getActiveBookings';
import getFoodItems from '@salesforce/apex/FoodOrderController.getFoodItems';
import placeFoodOrder from '@salesforce/apex/FoodOrderController.placeFoodOrder';
import getActiveOrders from '@salesforce/apex/FoodOrderController.getActiveOrders';
import getOrderHistory from '@salesforce/apex/FoodOrderController.getOrderHistory';
import cancelOrder from '@salesforce/apex/FoodOrderController.cancelOrder';

export default class FoodOrder extends LightningElement {
    @track selectedBooking;
    @track bookingOptions = [];
    @track specialNotes = '';
    @track foodItems = [];
    @track draftValues = [];

    @track activeOrders = [];
    @track orderHistory = [];

    columns = [
        { label: 'Item Name', fieldName: 'Name', type: 'text' },
        { label: 'Price', fieldName: 'Price__c', type: 'currency' },
        { label: 'Quantity', fieldName: 'Quantity__c', type: 'number', editable: true }
    ];

    // 1. Fetch Active Bookings
    @wire(getActiveBookings)
    wiredBookings({ data, error }) {
        if (data) {
            
            this.bookingOptions = data.map(b => ({
                label: b.Room__r.Name,
                value: b.Id
            }));
            //console.log(this.bookingOptions)
        } else if (error) {
            console.error(error);
        }
    }

    // 2. Fetch Food Items
    @wire(getFoodItems)
    wiredFoodItems({ data, error }) {
        if (data) {
            this.foodItems = data.map(f => ({
                Id: f.Id,
                Name: f.Name,
                Price__c: f.Price__c,
                Quantity__c: 0
            }
            
        ));
        //console.log(this.foodItems)    
    } 
        else if (error) {
            console.error(error);
        }
    }

    // 3. Fetch Orders
    connectedCallback() {
        this.loadOrders();
    }

    async loadOrders() {
    try {
        const [active, history] = await Promise.all([
            getActiveOrders(),
            getOrderHistory()
        ]);

        this.activeOrders = active || [];
        this.orderHistory = history || [];
        console.log(this.activeOrders,this.orderHistory);
    } catch (error) {
        console.error('Error loading orders:', error);
        this.showToast('Error', 'Failed to load orders', 'error');
    }
}

    handleBookingChange(event) {
        this.selectedBooking = event.detail.value;
    }

    handleNotesChange(event) {
        this.specialNotes = event.detail.value;
    }

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
            await placeFoodOrder({ bookingId: this.selectedBooking, specialNotes: this.specialNotes, items: orderedItems });
            this.showToast('Success', 'Order placed successfully!', 'success');
            this.loadOrders();
            this.resetForm();
        } catch (err) {
            console.error(err);
            this.showToast('Error', err.body.message, 'error');
        }
    }

    async handleCancel(event) {
        const orderId = event.target.dataset.id;
        try {
            await cancelOrder({ orderId });
            this.showToast('Success', 'Order cancelled.', 'success');
            this.loadOrders();
        } catch (err) {
            console.error(err);
            this.showToast('Error', err.body.message, 'error');
        }
    }

    resetForm() {
        this.selectedBooking = null;
        this.specialNotes = '';
        this.foodItems = this.foodItems.map(f => ({ ...f, Quantity__c: 0 }));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}

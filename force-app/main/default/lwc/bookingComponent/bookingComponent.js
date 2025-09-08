import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAvailableRooms from '@salesforce/apex/BookingController.getAvailableRooms';
import createBooking from '@salesforce/apex/BookingController.createBooking';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookingComponent extends NavigationMixin(LightningElement) {
    @track checkIn;
    @track checkOut;
    @track guests;
    @track roomType;
    @track rooms = [];
    @track selectedRoomId;
    @track selectedRoomPrice;

    get roomTypeOptions() {
        return [
            { label: 'Single', value: 'Single' },
            { label: 'Double', value: 'Double' },
            { label: 'Suite', value: 'Suite' }
        ];
    }

    get canSelectRoomType() {
        return this.checkIn && this.checkOut && this.guests > 0;
    }

    get roomOptions() {
        return this.rooms.map(r => {
            return { label: `${r.Name} (${r.Room_Type__c}) - ₹${r.Price_Per_Night__c}/night`, value: r.Id };
        });
    }

handleCheckInChange(event) { 
    this.checkIn = event.target.value;
    const today = new Date().toISOString().split('T')[0]; // yyyy-mm-dd

    if (this.checkIn < today) {
        this.showToast('Invalid Date', 'Check-in date cannot be in the past.', 'error');
        this.checkIn = null;
        return;
    }

    if (this.checkOut && this.checkOut <= this.checkIn) {
        this.showToast('Invalid Date', 'Checkout must be after Check-in.', 'error');
        this.checkOut = null;
    }
}

handleCheckOutChange(event) { 
    this.checkOut = event.target.value;
    const today = new Date().toISOString().split('T')[0];

    if (this.checkOut < today) {
        this.showToast('Invalid Date', 'Checkout date cannot be in the past.', 'error');
        this.checkOut = null;
        return;
    }

    if (this.checkIn && this.checkOut <= this.checkIn) {
        this.showToast('Invalid Date', 'Checkout must be after Check-in.', 'error');
        this.checkOut = null;
    }
}
    handleGuestsChange(event) { this.guests = event.target.value; }

    async handleRoomTypeChange(event) {
        this.roomType = event.detail.value;
        await this.fetchAvailableRooms();
    }

    handleRoomSelect(event) {
        this.selectedRoomId = event.detail.value;
        const room = this.rooms.find(r => r.Id === this.selectedRoomId);
        this.selectedRoomPrice = room ? room.Price_Per_Night__c : 0;
    }

    async fetchAvailableRooms() {
        try {
            this.rooms = await getAvailableRooms({ roomType: this.roomType });
            if (this.rooms.length === 0) {
                this.showToast('No Rooms Available', 'No available rooms for this type.', 'warning');
            }
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    async handleBookingSubmit() {
        if (!this.selectedRoomId) {
            this.showToast('Validation Error', 'Please select a room before booking.', 'error');
            return;
        }

        try {
            const nights = this.calculateNights(this.checkIn, this.checkOut);
            if (nights <= 0) {
                this.showToast('Validation Error', 'Checkout date must be after Checkin.', 'error');
                return;
            }

            const totalAmount = nights * this.selectedRoomPrice;

            await createBooking({
                checkIn: this.checkIn,
                checkOut: this.checkOut,
                noOfGuests: this.guests,
                roomId: this.selectedRoomId,
                totalAmount: totalAmount
            });

            this.showToast('Success', `Booking Confirmed! Total: ₹${totalAmount}`, 'success');
            this.resetForm();

            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/bookinglist'   // community page URL
                }
            });
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    calculateNights(checkIn, checkOut) {
        const inDate = new Date(checkIn);
        const outDate = new Date(checkOut);
        const diffTime = outDate - inDate;
        return diffTime / (1000 * 60 * 60 * 24); // days
    }

    resetForm() {
        this.checkIn = null;
        this.checkOut = null;
        this.guests = null;
        this.roomType = null;
        this.rooms = [];
        this.selectedRoomId = null;
        this.selectedRoomPrice = null;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}

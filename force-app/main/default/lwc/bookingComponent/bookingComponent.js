import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAvailableRooms from '@salesforce/apex/BookingController.getAvailableRooms';
import createBooking from '@salesforce/apex/BookingController.createBooking';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

    //to handle the validation of the form and send data to the apex class.

export default class BookingComponent extends NavigationMixin(LightningElement) {
     checkIn;
     checkOut;
     guests;
     roomType;
    @track rooms = [];
    selectedRoomId;
    selectedRoomPrice;
    //get methods returning the options to the html.
    get roomTypeOptions() {
        return [
            { label: 'Single', value: 'Single' },
            { label: 'Double', value: 'Double' },
            { label: 'Suite', value: 'Suite' }
        ];
    }
    //get method to check if the room type is selected or not.
    get canSelectRoomType() {
        return this.checkIn && this.checkOut && this.guests > 0;
    }
    //get method to get the options for the room type.
    get roomOptions() {
        return this.rooms.map(r => {
            return { label: `${r.Name} (${r.Room_Type__c}) - ₹${r.Price_Per_Night__c}/night`, value: r.Id };
        });
    }
    //handle input change events.
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
        this.checkIn=null;
    }
}
//handle checkout change events.
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
    //handle guests change events.
    handleGuestsChange(event) { 
        this.guests = event.target.value;
        if (this.guests > 4) {
            this.showToast('Validation Error', 'Maximum 4 guests per room.', 'error');
            this.guests=null;
        }
     }
     //on room type change events.
    async handleRoomTypeChange(event) {
        this.roomType = event.detail.value;
        await this.fetchAvailableRooms();
    }
    // handle room selection events based on room type by finding in the array.
    handleRoomSelect(event) {
        this.selectedRoomId = event.detail.value;
        const room = this.rooms.find(r => r.Id === this.selectedRoomId);
        this.selectedRoomPrice = room ? room.Price_Per_Night__c : 0;
    }
     // fetch available rooms based on the room type.
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
    // call the apex method to create a booking.
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
            //navigate to the booking list page for smooth experience.
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/bookinglist'   
                }
            });
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }
    //calulate the number of nights between checkin and checkout.
    calculateNights(checkIn, checkOut) {
        const inDate = new Date(checkIn);
        const outDate = new Date(checkOut);
        const diffTime = outDate - inDate;
        return diffTime / (1000 * 60 * 60 * 24); // days
    }
    //reset the form on success.
    resetForm() {
        this.checkIn = null;
        this.checkOut = null;
        this.guests = null;
        this.roomType = null;
        this.rooms = [];
        this.selectedRoomId = null;
        this.selectedRoomPrice = null;
    }
    // show toast method to show the user of whats happening.
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
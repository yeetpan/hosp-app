import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getBookingById from '@salesforce/apex/BookingController.getBookingById';
import cancelBooking from '@salesforce/apex/BookingController.cancelBooking';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class BookingDisplay extends NavigationMixin(LightningElement) {
     booking;
     error;
    recordId;

    wiredBookingResult; // store wire result for refreshApex

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef && pageRef.state.recordId) {
            this.recordId = pageRef.state.recordId;
        }
    }

    @wire(getBookingById, { bookingId: '$recordId' })
    wiredBooking(result) {
        this.wiredBookingResult = result;
        const { data, error } = result;
        if (data) {
            this.booking = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body?.message || 'Error loading booking';
            this.booking = undefined;
        }
    }

    get hasData() {
        return this.booking && !this.error;
    }

    get disableCancel() {
        return (
            this.booking?.Booking_Status__c === 'Cancelled' ||
            this.booking?.Booking_Status__c === 'Checked-Out'
        );
    }

    async handleCancel() {
        try {
            await cancelBooking({ bookingId: this.recordId });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Your booking has been cancelled.',
                    variant: 'success'
                })
            );

            //  Refresh wire to reflect updated status
            await refreshApex(this.wiredBookingResult);

        } catch (err) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error cancelling booking',
                    message: err.body?.message || 'Unknown error',
                    variant: 'error'
                })
            );
        }
    }

    handleBookAnother() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/booking' // community page for booking
            }
        });
    }

    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/bookinglist' // community page for booking list
            }
        });
    }
}

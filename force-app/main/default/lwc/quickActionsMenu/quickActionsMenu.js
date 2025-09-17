import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class QuickActionsMenu extends NavigationMixin(LightningElement) {

    navigateToBooking() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: '/booking' }
        });
    }

    navigateToBookingList() {   
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: '/bookinglist' }
        });
    }

    navigateToServiceRequest() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: '/servicerequest' }
        });
    }

    navigateToServiceRequestList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: '/servicerequestlist' }
        });
    }

    navigateToFoodOrder() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: '/foodorder' }
        });
    }
}

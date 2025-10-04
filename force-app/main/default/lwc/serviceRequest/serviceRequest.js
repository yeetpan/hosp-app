import { LightningElement, track } from 'lwc';
import getConfirmedBookings from '@salesforce/apex/CaseController.getConfirmedBookings';
import getBookingById from '@salesforce/apex/CaseController.getBookingById';
import createServiceRequest from '@salesforce/apex/CaseController.createServiceRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//columns to be displayed in the lightning data table.
const COLUMNS = [
    { label: 'Booking Id', fieldName: 'Name', type: 'text' },
    { label: 'Room Number', fieldName: 'roomId', type: 'text' },
    { label: 'Room Type', fieldName: 'roomType', type: 'text' },
    { label: 'Check-In', fieldName: 'Check_In_Date__c', type: 'date' },
    { label: 'Check-Out', fieldName: 'Check_Out_Date__c', type: 'date' },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'Open', name: 'open' }], menuAlignment: 'right' }
    }
];

export default class ServiceRequest extends LightningElement {
    //to keep a track of bookings achieved from booking controller.
    @track bookings = [];
    columns = COLUMNS;
    @track loading = true;

    // modal & form state
     isModalOpen = false;
     selectedBooking = null;
     subject = '';
     comments = '';
     requestType = '';

    connectedCallback() {
        this.loadBookings();
    }

    async loadBookings() {
        this.loading = true;
        try {
            const data = await getConfirmedBookings();
            this.bookings = (data || []).map(b => ({
                Id: b.Id,
                Name: b.Name,
                roomId: b.Room__r?.Name,
                roomType: b.Room__r?.Room_Type__c || '',
                Check_In_Date__c: b.Check_In_Date__c,
                Check_Out_Date__c: b.Check_Out_Date__c
            }));
        } catch (err) {
            this.showToast('Error', err?.body?.message || err.message, 'error');
        } finally {
            this.loading = false;
        }
    }

    // row action from datatable: open modal with booking prefill
    async handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'open') {
            await this.openForBooking(row.Id);
        }
    }

    async openForBooking(bookingId) {
        try {
            const b = await getBookingById({ bookingId });
            this.selectedBooking = b;
            this.subject = `Service Request for Booking ${b.Name}`;
            this.comments = '';
            this.requestType = ''; // reset dropdown
            this.isModalOpen = true;
        } catch (err) {
            this.showToast('Error', err?.body?.message || err.message, 'error');
        }
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedBooking = null;
        this.subject = '';
        this.comments = '';
        this.requestType = '';
    }

    onSubjectChange(event) {
        this.subject = event.target.value;
    }

    onCommentsChange(event) {
        this.comments = event.target.value;
    }

    onRequestTypeChange(event) {
        this.requestType = event.detail.value;
    }

    get requestTypeOptions() {
        return [
            { label: 'Cleaning', value: 'Cleaning' },
            { label: 'Maintenance', value: 'Maintenance' },
            { label: 'Billing', value: 'Billing' },
            { label: 'Room Service', value: 'Room Service' },
            {label:'Refund',value:'Refund'}
        ];
    }
    //validate all fields are present or not.
    validateForm() {
        if (!this.subject || !this.comments || !this.requestType) {
            this.showToast(
                'Validation',
                'Please fill Subject, Comments, and Request Type before submitting.',
                'warning'
            );
            return false;
        }
        return true;
    }
    //call apex method to create service request.
    async handleCreateRequest() {
        if (!this.validateForm()) return;

        try {
            await createServiceRequest({
                subject: this.subject,
                comments: this.comments,
                bookingId: this.selectedBooking ? this.selectedBooking.Id : null,
                requestType: this.requestType
            });

            this.showToast('Success', `Service request created successfully!`, 'success');
            this.closeModal();
            await this.loadBookings(); // to reflect changes.
        } catch (err) {
            this.showToast('Error', err?.body?.message || err.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}

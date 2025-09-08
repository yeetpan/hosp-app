import { LightningElement, wire, track } from 'lwc';
import getUserBookings from '@salesforce/apex/BookingController.getUserBookings';
import { NavigationMixin } from 'lightning/navigation';

const COLUMNS = [
    {
        label: 'Booking Id',
        fieldName: 'bookingLink',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_self' },
        cellAttributes: { alignment: 'left' }
    },
    { label: 'Room Name', fieldName: 'roomName', type: 'text' },
    { label: 'Room Type', fieldName: 'roomType', type: 'text' },
    { label: 'Check-In', fieldName: 'checkIn', type: 'date' },
    { label: 'Check-Out', fieldName: 'checkOut', type: 'date' },
    { label: 'Guests', fieldName: 'guests', type: 'number' },
    { label: 'Total Amount', fieldName: 'totalAmount', type: 'currency' },
    { label: 'Status', fieldName: 'status', type: 'text' }
];

export default class BookingList extends NavigationMixin(LightningElement) {
    @track bookings = [];
    columns = COLUMNS;
    loading = true;

    // default filter => show Confirmed + Checked-In
    @track selectedStatus = 'Active';

    statusOptions = [
        { label: 'Active (Confirmed & Checked-In)', value: 'Active' },
        { label: 'Confirmed', value: 'Confirmed' },
        { label: 'Checked-In', value: 'Checked-In' },
        { label: 'Cancelled', value: 'Cancelled' },
        { label: 'Checked-Out', value: 'Checked-Out' },
        { label: 'All', value: 'All' }
    ];

    @wire(getUserBookings)
    wiredBookings({ data, error }) {
        if (data) {
            this.bookings = data.map(b => ({
                Id: b.Id,
                Name: b.Name,
                bookingLink: `/bookingdisplay?recordId=${b.Id}`,
                roomName: b.Room__r?.Name,
                roomType: b.Room__r?.Room_Type__c,
                checkIn: b.Check_In_Date__c,
                checkOut: b.Check_Out_Date__c,
                guests: b.Number_Of_Guests__c,
                totalAmount: b.Total_Amount__c,
                status: b.Booking_Status__c
            }));
            this.loading = false;
        } else if (error) {
            console.error(error);
            this.loading = false;
        }
    }

    //  handle filter change
    handleFilterChange(event) {
        this.selectedStatus = event.detail.value;
    }

    //  filtered data for datatable
    get filteredBookings() {
        if (this.selectedStatus === 'All') {
            return this.bookings;
        }
        if (this.selectedStatus === 'Active') {
            return this.bookings.filter(
                b => b.status === 'Confirmed' || b.status === 'Checked-In'
            );
        }
        return this.bookings.filter(b => b.status === this.selectedStatus);
    }
}

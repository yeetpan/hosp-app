import { LightningElement, wire, track } from 'lwc';
import getDashboardStats from '@salesforce/apex/DashboardController.getDashboardStats';

export default class Dashboard extends LightningElement {
    @track stats = {};

    @wire(getDashboardStats)
    wiredStats({ data, error }) {
        if (data) {
            this.stats = data;
        } else if (error) {
            console.error(error);
        }
    }

    get orderCompletionPercent() {
        return this.stats.TotalOrders ? Math.round((this.stats.CompletedOrders / this.stats.TotalOrders) * 100) : 0;
    }

    get bookingActivePercent() {
        return this.stats.TotalBookings ? Math.round((this.stats.ActiveBookings / this.stats.TotalBookings) * 100) : 0;
    }

    get requestClosedPercent() {
        return this.stats.TotalRequests ? Math.round((this.stats.ClosedRequests / this.stats.TotalRequests) * 100) : 0;
    }
}

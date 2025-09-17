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

}

import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getDashboardStats from '@salesforce/apex/DashboardController.getDashboardStats';

export default class Dashboard extends LightningElement {
    @track stats = {};
    wiredstatsResult;
    @wire(getDashboardStats)
    wiredStats(wiredstatsResult) {
        this.wiredstatsResult== wiredstatsResult;
        const { data, error } = wiredstatsResult;
        if (data) {
            this.stats = data;
        }
        if (error) {
            console.error(error);
        }
    }
    connectedCallback(){
        refreshApex(this.wiredstatsResult);
    }
}

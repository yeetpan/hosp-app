import { LightningElement, wire, track } from 'lwc';
import getCases from '@salesforce/apex/CaseController.getCases';

export default class ServiceRequestCards extends LightningElement {
    @track cases = [];
    @track error;
    loading = true;

    @wire(getCases)
    wiredCases({ data, error }) {
        if (data) {
            this.cases = data;
            this.error = undefined;
            this.loading = false;
        } else if (error) {
            this.error = error.body?.message || 'Error fetching cases';
            this.cases = [];
            this.loading = false;
        }
    }

    get hasCases() {
        return this.cases && this.cases.length > 0;
    }
}

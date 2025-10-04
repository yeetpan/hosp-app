import { LightningElement, wire, track } from 'lwc';
import getCases from '@salesforce/apex/CaseController.getCases';
// displays status of cases in readable only format.
export default class ServiceRequestCards extends LightningElement {
    @track cases = [];
     error;
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
    //returns the cases to be displayed.
    get hasCases() {
        return this.cases && this.cases.length > 0;
    }
}

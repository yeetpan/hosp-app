public with sharing class QueuableExample implements Queueable,Finalizer {
    Contact contPassed;
    public QueuableExample(Contact con){
        contPassed=con;
    }
    public void execute(QueueableContext context) {
        contPassed.LastName='Chocolate';
        contPassed.FirstName='Queuable';
        update contPassed;
        
    }

    public void execute(FinalizerContext context){
        //wonderful for logging qeueable jobs.
        context.getRequestId();
    }

}
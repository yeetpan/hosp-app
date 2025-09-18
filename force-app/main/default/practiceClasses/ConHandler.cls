public with sharing class ConHandler {
    private static Boolean isafterInsertRunning=false;
    public static void beforeInsert(List<Contact> contacts){
        System.debug(Trigger.isBefore);
        System.debug(Trigger.isInsert);
        
        Set<String>emailSet=new Set<String>();
        for(Contact con:contacts){
            if(String.isNotBlank(con.Email)){
                emailSet.add(con.Email);
            }
            else{
                con.addError('Email is required');
            }
           
        }
        
        //Use Map<String, Id> duplicateCheck to detect duplicate Email within same batch.
        Map<String, Id> duplicateCheck=new Map<String, Id>();        
        for(Contact con:contacts){
            if(duplicateCheck.containsKey(con.Email)){
                con.addError('Duplicate Email');
                System.debug(con.Id);
            }
            else{   
                duplicateCheck.put(con.Email,con.Id);
        }
    }
}

    public static void beforeUpdate(List<Contact> contacts,Map<Id,Contact> oldMap){
        System.debug(Trigger.isBefore);
        System.debug(Trigger.isUpdate);
        Map<Id,String>changedRecords=new Map<Id,String>();
        for(Contact con:contacts){
            if(con.Email!=oldMap.get(con.Id).Email){
                con.addError('Email cannot be changed');
                changedRecords.put(con.Id,con.LasttName);
            }
        }
        System.debug(changedRecords);
    }

    public static void beforeDelete(List<Contact>contacts){
        List<Id>cons=new List<Id>();
        for(Contact con:contacts){
            cons.add(con.Id);
        }
        List<Id> accIds=new List<Id>();
        for(Contact con:contacts){
            if(acc.Id!=null){
                accIds.add(con.AccountId);
            }
        }

        Map<Id,List<Case>> caseMap=new Map<Id,List<Case>>();
        List<Case>querycase=[SELECT ContactId FROM Case WHERE ContactId IN:cons];
        for(Case c:querycase){
            if(caseMap.containsKey(c.ContactId)){
                caseMap.get(c.ContactId).add(c);
            }
            else{
                caseMap.put(c.ContactId,new List<Case>{c});
            }
        }

        Map<Id,List<Opportunity>> oppMap=new Map<Id,List<Opportunity>>();
        List<Opportunity>queryopp=[SELECT AccountId FROM Opportunity WHERE AccountId IN:accIds];
        for(Opportunity opp:queryopp){
            if(oppMap.containsKey(opp.AccountId)){
                oppMap.get(opp.AccountId).add(opp);
            }
            else{
                oppMap.put(opp.AccountId,new List<Opportunity>{opp});
            }
    }
    
    for(Contact con:contacts){
        if(caseMap.containsKey(con.Id)){
            con.addError('Contact is related to Cases');
        }
        if(oppMap.containsKey(con.AccountId)){
            con.addError('Contact is related to Opportunities');
        }
}
}

public static void afterInsert(List<Contact> contacts){
    if(isafterInsertRunning){
        System.debug('The Code has already been runned.');
        return;
    }
    Integer successCounts=0;
    Integer failureCounts=0;
    isafterInsertRunning=true;
    List<Task>tasks=new List<Task>();
    List<Case>cases=new List<Case>();
    for(Contact con:contacts){
        Task t=new Task();
        t.WhatId=con.Id;
        t.Subject='Welcome Call';
        tasks.add(t);
        Case c=new Case();
        c.ContactId=con.Id;
        c.Subject='Initial Support';
        cases.add(c);
    }
    Database.SaveResult[] taskResults=Database.insert(tasks,false);
    Database.SaveResult[] caseResults=Database.insert(cases,false);
    Set<Id>successIds=new Set<Id>();
    Map<Id,String>failedMap=new Map<Id,String>();
    for(Database.SaveResult sr:taskResults){
        if(!sr.isSuccess()){
            failureCounts++;
            failedMap.put(sr.getId(),sr.getErrors()[0].getMessage());
            con.addError('Task could not be created');
        }
        successCounts++;
    }
    for(Database.SaveResult sr:caseResults){
        if(!sr.isSuccess()){
            failureCounts++;
            failedMap.put(sr.getId(),sr.getErrors()[0].getMessage());
            con.addError('Case could not be created');
        }
        failureCounts++;
    }
}
public static void afterDelete(List<Contact> cons){
    Set<Id>deletedContactIds=new Set<Id>();
    for(Contact con:cons){
        deletedContactIds.add(con.Id);
    }
    List<Case>queryCase=[SELECT Id,Status FROM Case WHERE ContactId IN:deletedContactIds AND Status='Open'];
    List<Task>queryTask=[SELECT Id,Status FROM Task WHERE WhoId IN:deletedContactIds AND Status!='Completed'];

    List<Database.DeleteResult> caseResults=Database.delete(queryCase,false);
    List<Database.DeleteResult> taskResults=Database.delete(queryTask,false);

    Map<Id,String>caseFailures=new Map<Id,String>();
    Map<Id,String>taskFailures=new Map<Id,String>();
    for(Database.DeleteResult dr:caseResults){
        if(!dr.isSuccess()){
            caseFailures.put(dr.getId(),dr.getErrors()[0].getMessage());
            System.debug('Case could not be deleted');
        }
    }
    for(Database.DeleteResult dr:taskResults){
        if(!dr.isSuccess()){
            taskFailures.put(dr.getId(),dr.getErrors()[0].getMessage());
            System.debug('Task could not be deleted');
        }

    }
}
public static void afterUndelete(List<Contact> cons){
    Set<Id>restoredContactIds=new Set<Id>();
    for(Contact con:cons){
        restoredContactIds.add(con.Id);
    }
    List<Task>queryTask=[SELECT Id,Status FROM Task WHERE WhoId IN:restoredContactIds AND Status='Closed'];
    for(Task t:queryTask){
        t.Status='Open';
    }
    List<Contact>queryContact=[SELECT Id,IsPrimary__c,Active__c FROM Contact WHERE IsPrimary__c=true];
    for(Contact con:queryContact){
        con.Active__c=true;
    }
    Database.SaveResult[] taskResults=Database.update(queryTask,false);
    Database.SaveResult[] contactResults=Database.update(queryContact,false);  
    
    Map<Id,String>taskFailures=new Map<Id,String>();
    Map<Id,String>contactFailures=new Map<Id,String>();
    for(Database.SaveResult sr:taskResults){
        if(!sr.isSuccess()){
            taskFailures.put(sr.getId(),sr.getErrors()[0].getMessage());    
            System.debug('Task could not be updated');

        } }

    for(Database.SaveResult sr:contactResults){
        if(!sr.isSuccess()){
            contactFailures.put(sr.getId(),sr.getErrors()[0].getMessage());    
            System.debug('Contact could not be updated');

        } }


}
}
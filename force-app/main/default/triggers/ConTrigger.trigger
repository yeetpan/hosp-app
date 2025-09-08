trigger ConTrigger on Contact (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after delete, 
    after undelete
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ConHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ConHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            ConHandler.beforeDelete(Trigger.old);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ConHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isDelete) {
            ConHandler.afterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            ConHandler.afterUndelete(Trigger.new);
        }
    }
}

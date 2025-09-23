public with sharing class UserUtils {
    //middleware for checking contact session.
    @AuraEnabled(cacheable=true)
    public static Id getSessionContactId() {
        User u = [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return u.ContactId;
    }
}
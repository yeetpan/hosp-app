public with sharing class UserUtils {
    //for sharing data with LWC.
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
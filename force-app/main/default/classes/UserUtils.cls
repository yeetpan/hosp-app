public with sharing class UserUtils {
    //middleware for checking contact session.
    @AuraEnabled(cacheable=true)
    // this method will be used for checking the user is valid for performing actions on the experience cloud portal.
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
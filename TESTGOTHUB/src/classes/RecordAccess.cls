public Class RecordAccess {

    public Boolean canEdit    {get;set;}

    public Boolean isClone    {get;set;}
    
    public RecordAccess(ApexPages.StandardController standardController) {
        canEdit = canEdit(standardController.getId());
        
        if(ApexPages.currentPage().getParameters().get('clone')=='1') {
            isClone = true;
            system.debug('TESTING');
        }     
    }

    public static Boolean canEdit(String aRecordID) {
        Boolean hasEditRight = true;
        
        if(aRecordID != null) {
            hasEditRight = [SELECT RecordId, HasEditAccess FROM UserRecordAccess
                            WHERE UserId = :UserInfo.getUserId() AND RecordId = :aRecordID].HasEditAccess;        
        }

        return hasEditRight; 
    }

    public static Boolean canTransfer(String aRecordID) {
        Boolean hasTransferAccess  = false;
        
        if(aRecordID != null) {
            hasTransferAccess = [SELECT RecordId, HasTransferAccess FROM UserRecordAccess
                                 WHERE UserId = :UserInfo.getUserId() 
                                 AND RecordId = :aRecordID].HasTransferAccess ;        
        }

        return hasTransferAccess; 
    }

}
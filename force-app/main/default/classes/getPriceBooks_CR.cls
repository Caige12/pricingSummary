//test_getPriceBooks_CR => test class
public with sharing class getPriceBooks_CR{
    //do i make this cacheable
    @auraEnabled
    public static savePBE(list<pricebookentry> entries){
        if (entries == null || entries.isEmpty()) {
            // Checks if priceBookEntry is Empty and return Error
            return new SavePBEResponse('error','No entries provided.');
        }
        // List of Errors, replaces MessBack return from Older Class
        List<String> errors = new List<String>();
        try{
            Database.SaveResult[] results = Database.upsert(entries, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err : results[i].getErrors()) {
                        errors.add('Row ' + i + ': ' + err.getMessage());
                    }
                }
            }
            // Checks For any errors that slipped and return 
            //### Rework StrongType of Wrapper ###
            if (errors.isEmpty()) {
                SavePBEResponse.status = 'success';
                SavePBEResponse.message = 'All entries saved!';

            } else {
                SavePBEResponse.error = 'Not Valid Response!';
            } 
        } catch(exception e){
            system.debug(e);
            //returns message with Wrapper
            return new SavePBEResponse('error', e.getMessage());
        } 
    }
    public with sharing class SavePBEResponse {
    @AuraEnabled
    public String status { get; set; }
    
    @AuraEnabled
    public String message { get; set; }
    
    @AuraEnabled
    public List<String> errors { get; set; }
    }
}
@isTest
public class test_getPriceBooks_CR {
@isTest
static void Test_SavePBE_Error() {
    
    //Temp Product
    Product2 product= new Product2(
        Name = 'TempProductName',
        ProductCode = 'FS1008-QT',
        Description = 'Empty',
        IsActive = true,
        Family = 'T123',
        Floor_Price__c = 99.99
    );
    insert product;
    
    id priceBookStandard = Test.getStandardPricebookId();
    //Standard PriceBook Entry
    PriceBookEntry StandardPriceBookEntry = new PriceBookEntry(PriceBook2Id = priceBookStandard, Product2Id = product.id, unitprice = 90, IsActive = True, UseStandardPrice=False);
    insert StandardPriceBookEntry;
    //Setup pricebook
    Pricebook2 priceBook = new Pricebook2(Name = 'Custom_PriceBook', IsActive = true);
    insert priceBook;

    //Creates PriceBookEntry 
    PricebookEntry priceBookEntry1 = new PricebookEntry(
        Product2Id = product.Id,
        Pricebook2Id = priceBook.Id,
        UnitPrice = 100,
        IsActive = true,
        UseStandardPrice = false
    );
    //Creates second PricebookEntry for checking partial duplication
    PricebookEntry priceBookEntry2 = new PricebookEntry(
        Product2Id = product.Id,
        Pricebook2Id = priceBook.Id,
        UnitPrice = 110,
        IsActive = true,
        UseStandardPrice = false
    );
    //PriceBookEntry Error
    PricebookEntry priceBookEntry3 = new PricebookEntry(
        Product2Id = product.Id,
        Pricebook2Id = priceBook.Id,
        UnitPrice = 110,
        IsActive = true,
        UseStandardPrice = false
    );
    
    // This Didn't use the Catch System but did Fail in the Database Catch System
    
    //PriceBook and Product with Invalid ID
    //Id fakeProductID = '01t000000000000AAA';
    //Id fakePriceBookID = '01s000000000000AAA';
    //PricebookEntry brokenEntry = new PricebookEntry(
   	//	Product2Id = fakeProductID, 
    //	Pricebook2Id = fakePriceBookID,
    //	UnitPrice = 50,
    //	IsActive = true,
    //  UseStandardPrice = false
	//);
	
    // List the entries
    List<PricebookEntry> entries = new List<PricebookEntry>{priceBookEntry1, priceBookEntry2};
   	List<PricebookEntry> emptyEntry = new List<PricebookEntry>{};
    List<PricebookEntry> entry = new List<PricebookEntry>{priceBookEntry1};
    List<PricebookEntry> errorEntries = new List<PricebookEntry>{priceBookEntry3};
    // Uses null pointer to Get Catch System since Invalid Entry didn't
    List<PricebookEntry> exceptionEntry = new List<PricebookEntry>{null};
    //Start of the Test
    Test.startTest();   
    	//Testing Error in Null/Empty PriceBooks
    	getPriceBooks_CR.savePBEResponse responseNull = getPriceBooks_CR.savePBE(null);
    	getPriceBooks_CR.savePBEResponse responseEmpty = getPriceBooks_CR.savePBE(emptyEntry);

    
    	//If we need Wrapper use ->
    	getPriceBooks_CR.SavePBEResponse result = getPriceBooks_CR.savePBE(entries);
        //If we need string return -> 
        //String response = getPriceBooks.savePBE(new List<PriceBookEntry>{priceBookEntry2});
        
        //Recieving Perfect Entry
        getPriceBooks_CR.SavePBEResponse resultPerfect = getPriceBooks_CR.savePBE(entry);
    
        //Testing Duplicate Messsage
        //and Checker
		getPriceBooks_CR.SavePBEResponse duplicates = getPriceBooks_CR.savePBE(entries);
    	
    	//Recieving Full Error/Failed Entries
    	getPriceBooks_CR.SavePBEResponse errors = getPriceBooks_CR.savePBE(errorEntries);
    	getPriceBooks_CR.SavePBEResponse exceptError = getPriceBooks_CR.savePBE(exceptionEntry);
    Test.stopTest();
    
    //Assert Testing Null Pointers
    System.assertNotEquals(null, result, 'Results shouldnt be null');
    System.assert(responseNull.errors.get(0) == 'Entry is Empty','Entry was Null');
    System.assert(responseEmpty.errors.get(0) == 'Entry is Empty','Entry was Empty');
    //Assert Perfect Entry
    System.assert(resultPerfect.status == 'Success','Should return Success with no Dupes');
    //System.assertNotEquals(null, result.status, 'Status shouldnt be null');
    //Assert Status Pointer
    System.assert(result.status == 'Success' || result.status == 'Success with Dupes' || result.status == 'error', 'Status needs to be Valid');
    //Assert Success with Dupes
    if (result.status == 'Success with Dupes') {
        //Testing the General Case of Dupes
        System.assert(result.errors != null && result.errors.size() > 0, 'Success with dupes should return error');
        //Testing the sizing of the dupes example: If there was one dupe instead of saying there was just dupes
        System.assert(result.duplicates != null && result.duplicates.size() == 1,'Should detect one duplicate');
    }
    //Assert Error Entry
    System.assertEquals('failed', errors.status, 'Should return Failed');
    System.assert(errors.errors != null && errors.errors.size() > 0, 'Shows there are Errors');
    //Asserting Catch Error
    System.assertEquals('error', exceptError.status, 'Catch block should return error status');
    System.assert(exceptError.errors != null && exceptError.errors.size() > 0, 'Catch block should provide error messages');
    
	}   
}
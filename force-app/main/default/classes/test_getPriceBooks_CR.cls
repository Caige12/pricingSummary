@isTest
public class test_getPriceBooks_CR {
@isTest
static void Test_SavePBE_Error() {
    //Temp Product
    Product2 product= new Product2(
        name = 'Products',
        ProductCode = 'TEST123',
        IsActive = true,
        Product_Status__c = 'Stock',
        //Subcategory__c = '---',
        //Go to Product2 Page in Setup to replace
        Product_Family__c = 'T123',
        Floor_Type__c = 'Floor',
        Floor_Price__c = 99.99
    );
    insert prod;
    
    id priceBookStandard = Test.getStandardPricebookId();
    //Standard PriceBook Entry
    PriceBookEntry StandardPriceBookEntry = new PriceBookEntry(PriceBook2Id = priceBookStandard, Product2Id = prod.id, unitprice = 90, IsActive = True, UseStandardPrice=False);
    insert StandardPriceBookEntry;
    //Setup pricebook
    Pricebook2 priceBook = new Pricebook2(Name = 'Custom_PriceBook', IsActive = true);
    insert priceBook;

    //Creates PriceBookEntry 
    PricebookEntry priceBookEntry1 = new PricebookEntry(
        Product2Id = prod.Id,
        Pricebook2Id = priceBook.Id,
        UnitPrice = 100,
        IsActive = true,
        UseStandardPrice = false
    );
    //Creates second PricebookEntry for checking partial duplication
    PricebookEntry priceBookEntry2 = new PricebookEntry(
        Product2Id = prod.Id,
        Pricebook2Id = pb.Id,
        UnitPrice = 110,
        IsActive = true,
        UseStandardPrice = false
    );
    // List the entries
    List<PricebookEntry> entries = new List<PricebookEntry>{priceBookEntry1, priceBookEntry2};
    //Start of the Test
    Test.startTest();
        SavePBEResponse result = getPriceBooks.savePBE(entries);
        //If we need string return -> String response = getPriceBooks.savePBE(new List<PriceBookEntry>{priceBookEntry2});
    Test.stopTest();
    //Assert Testing
    System.assertNotEquals(null, result, 'Results shouldnt be null');
    System.assertNotEquals(null, result.status, 'Status shouldnt be null');
    System.assert(result.status == 'success' || result.status == 'partial error' || result.status == 'error', 'Status needs to be Valid');
    
    if (result.status == 'partial error') {
        System.assert(result.errors != null && result.errors.size() > 0, 'partial errors should return error');
    }
}    
}
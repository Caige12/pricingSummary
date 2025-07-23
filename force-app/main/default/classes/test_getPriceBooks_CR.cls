@isTest
public class test_getPriceBooks_CR {
@isTest
static void Test_SavePBE() {
    //Temp Product
    Product2 product= new Product2(
        name = 'Products',
        ProductCode = 'TEST123',
        IsActive = true,
        Product_Status__c = 'Stock',
        Subcategory__c = 'Chemicals-QuickSilver',
        Product_Family__c = 'T123',
        Floor_Type__c = 'Floor',
        Floor_Price__c = 99.99
    );
    insert prod;

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
    PricebookEntry pbe2 = new PricebookEntry(
        Product2Id = prod.Id,
        Pricebook2Id = pb.Id,
        UnitPrice = 110,
        IsActive = true,
        UseStandardPrice = false
    );
    // List the entries
    List<PricebookEntry> entries = new List<PricebookEntry>{ pbe1, pbe2 };
    //Start of the Test
    Test.startTest();
        SavePBEResponse result = getPriceBooks.savePBE(entries);
    Test.stopTest();
    System.assertNotEquals(null, result, 'Response should not be null');
    System.assertNotEquals(null, result.status, 'Status should not be null');
    System.assert(result.status == 'success' || result.status == 'partial error' || result.status == 'error', 'Status must be valid');
    
    if (result.status == 'partial error') {
        System.assert(result.errors != null && result.errors.size() > 0, 'Partial should return errors');
    }
}    
}
//test_getPriceBooks => test class
public with sharing class getPriceBooks {
    @AuraEnabled(cacheable=true)
  public static list<buyergrouppricebook> getPriceBookIds(string accountId){
      
        list<String> multiGroups = new list<string>();        
            for(buyergroupmember x: [select buyergroupid, name from buyergroupmember where buyerid =: accountId ]){
                system.debug('x '+ x);
                multiGroups.add(x.buyergroupid);
            }
            list<buyergrouppricebook> pricebookIds = new list<buyergrouppricebook>();
            if(multiGroups.size()>0){
                
                //limit to active price book
                for(buyergrouppricebook y: [select Pricebook2Id, Pricebook2.Name, Name,Priority, BuyerGroup.Name from buyergrouppricebook where buyergroupid IN: (multiGroups)]){
                   system.debug('y '+ y); 
                    
                    pricebookIds.add(y);
                }
           } 
        return pricebookIds; 
         
    }
    
    @auraEnabled(cacheable=true)
    public static list<pricebookentry> getBestPrice(list<string> priceBookIds, string productId){
        list<string> pb = priceBookIds; 
        list<pricebookentry> bestPrice = [select Id, Pricebook2Id,Pricebook2.Name,Pricebook2.IsStandard, 
                                          UnitPrice, Floor_Price__c, Level_1_UserView__c,Level_One_Margin__c, Level_2_UserView__c,Level_2_Margin__c,
                                          Product_Cost__c, Sub_Cat__c from PricebookEntry 
                                          where IsActive = true and Pricebook2Id in: (pb) and Product2ID=: productId 
                                         ORDER BY UnitPrice ASC limit 1];
        return bestPrice; 
    }
    
        @auraEnabled(cacheable=true)
    public static list<pricebookentry> priorityBestPrice(list<string> priceBookIds, string productId){
        list<pricebookentry> priorityPrice = new list<pricebookentry>();
        for(string x:priceBookIds){
              priorityPrice = [select Id, Pricebook2Id,Pricebook2.Name,Pricebook2.IsStandard,Pricebook2.Priority__c, List_Margin__c, Product2Id,Cost_Has_Decreased__c, 
                                          UnitPrice, Floor_Price__c, Level_1_UserView__c,Level_One_Margin__c, Level_2_UserView__c,Level_2_Margin__c,
                                          Product_Cost__c, Sub_Cat__c from PricebookEntry 
                                          where IsActive = true and Pricebook2Id =:x and Product2ID=: productId];  
             
            if(priorityPrice.size()==0){
            
                continue; 
            }else{
                break;
            }
        }

        return priorityPrice; 
    }
    //Pricing Summary tool. 
    //All price book entries based on the price books available to an account. The pricebook id's are assigned in order in the lwc priceSummaryHolder.  
    @auraEnabled(cacheable=true)
    public static list<pricebookentry> allPriceBooks(list<string> priceBookIds, string productId){
        list<pricebookentry> priorityPrice = new list<pricebookentry>();
        for(string x:priceBookIds){ 
        	list<pricebookentry> single = [select Id, Pricebook2Id, Product2.Name, ProductCode, Price_Book_Name__c, UnitPrice, Product_Cost__c, Floor_Price__c,
                               		List_Margin__c, Hold_Margin__c, Floor_Margin__c, Min_Margin__c, Product2Id, List_Margin_Calculated__c, Sub_Cat__c from pricebookentry
                                	where IsActive = true and Pricebook2Id =:x and Product2ID=: productId and pricebook2.My_Price_Book__c= true];
            if(single.size()>0){
            	priorityPrice.add(single[0]);    
            } 
             
        }

        return priorityPrice; 
    }
    //order by best price model for pricingSummary app 
        @auraEnabled
    public static list<pricebookentry> getBestPriceString(list<string> priceBooksAcc, string priceField, string productId, string orderBy){
        list<string> pb = priceBooksAcc; 
        string find = 'select Floor_Price__c, Level_One_Margin__c, Level_1_UserView__c, Level_2_Margin__c, Level_2_UserView__c,Product2.Name, Product2.ProductCode, ' 
           + 'Pricebook2Id, UnitPrice, Product_Cost__c, Price_Book_Name__c,Name, Pricebook2.IsStandard,ProductCode, Product2Id, List_Margin__c,List_Margin_Calculated__c, Hold_Margin__c,'
           + 'Floor_Margin__c, Min_Margin__c from PricebookEntry'
        + ' where IsActive = true and Pricebook2Id IN (\''+String.join(priceBooksAcc,'\',\'')+'\') and  Product2ID=\''+ productId+ '\''; 
        find += orderBy;     
        //if(limitor> 0){
          //  find += 'limit '+= limitor
        //}
	system.debug(find); 
        list<pricebookentry> bestPrice = Database.query(find);
        return bestPrice; 
    }
    //get product price; 
   @auraEnabled
    public static list<pricebookentry> getProductPrice(string productId, string priceField,  string orderBy){
     
        string find = 'select Floor_Price__c, Level_One_Margin__c, Level_1_UserView__c, Level_2_Margin__c, Level_2_UserView__c,Product2.Name, Product2.ProductCode, ' 
           + 'Pricebook2Id, UnitPrice, Product_Cost__c, Price_Book_Name__c,Name, Pricebook2.IsStandard,ProductCode, Product2Id, List_Margin__c,List_Margin_Calculated__c, Hold_Margin__c,'
           + 'Floor_Margin__c, Min_Margin__c from PricebookEntry'
        + ' where IsActive = true and pricebook2.My_Price_Book__c= true and Product2ID=\''+ productId+ '\''; 
        find += orderBy;     
        system.debug(find); 
        //if(limitor> 0){
          //  find += 'limit '+= limitor
        //}

        list<pricebookentry> bestPrice = Database.query(find);
        return bestPrice; 
    }
    //this gets products that where updated by the counter
       @auraEnabled
    public static list<pricebookentry> getCounterUpdates(){
     
        string find = 'select Floor_Price__c, Level_One_Margin__c, Level_1_UserView__c, Level_2_Margin__c, Level_2_UserView__c,Product2.Name, Product2.ProductCode, ' 
           + 'Pricebook2Id, UnitPrice, Product_Cost__c, Price_Book_Name__c,Name, Pricebook2.IsStandard,ProductCode, Product2Id, List_Margin__c,List_Margin_Calculated__c, Hold_Margin__c,'
           + 'Floor_Margin__c, Min_Margin__c from PricebookEntry'
        + ' where IsActive = true and pricebook2.My_Price_Book__c= true and Last_Modified_by_Counter__c = true'; 
        

        list<pricebookentry> bestPrice = Database.query(find);
        return bestPrice; 
    }
    
    @auraEnabled
    public static list<pricebookentry> checkPriceBooks(string pricebook, string productId, string orderBy){
     
        string find = 'select Floor_Price__c, Level_One_Margin__c, Level_1_UserView__c, Level_2_Margin__c, Level_2_UserView__c,Product2.Name, Product2.ProductCode, ' 
           + 'Pricebook2Id, UnitPrice, Product_Cost__c, Price_Book_Name__c,Name, Pricebook2.IsStandard,ProductCode, Product2Id, List_Margin__c,List_Margin_Calculated__c, Hold_Margin__c, '
           + 'Floor_Margin__c, Min_Margin__c, Agency_Product__c, Sub_Cat__c from PricebookEntry'
        + ' where IsActive = true and Pricebook2Id =\''+ pricebook + '\''; 
        if(!string.isBlank(productId)){
            find += ' and Product2ID=\''+ productId+ '\''; 
        }
        find += orderBy;     
        system.debug(find); 
        //if(limitor> 0){
          //  find += 'limit '+= limitor
        //}

        list<pricebookentry> check = Database.query(find);
        return check; 
    }
    
        @auraEnabled
    public static list<pricebookentry> addToPriceBook(string pricebook, string productId, string orderBy){
     
        string find = 'select Floor_Price__c, Level_One_Margin__c, Level_1_UserView__c, Level_2_Margin__c, Level_2_UserView__c,Product2.Name, Product2.ProductCode, ' 
           + 'Pricebook2Id, UnitPrice, Product_Cost__c, Price_Book_Name__c,Name, Pricebook2.IsStandard,ProductCode, Product2Id, List_Margin__c,List_Margin_Calculated__c, Hold_Margin__c, '
           + 'Floor_Margin__c, Min_Margin__c, Agency_Product__c from PricebookEntry'
        + ' where IsActive = true and Pricebook2Id =\''+ pricebook + '\''; 
        if(!string.isBlank(productId)){
            find += ' and Product2ID=\''+ productId+ '\''; 
        }
        find += orderBy;     
        system.debug(find); 
        //if(limitor> 0){
          //  find += 'limit '+= limitor
        //}

        list<pricebookentry> check = Database.query(find);
        return check; 
    }
    
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
            if (errors.isEmpty()) {
                return new SavePBEResponse('success', 'All entries saved.');
            } else {
                return new SavePBEResponse('Catch Error', 'Some entries failed to save.', errors);
            } 
        } catch(exception e){
            system.debug(e);
            //returns message with Wrapper
            return new SavePBEResponse('error', e.getMessage());
        } 
    }
    public with sharing class pricingWrapper{
        @AuraEnabled 
        public list<AggregateResult> open {get; set;}
        @AuraEnabled 
        public list<AggregateResult> salesAVG {get; set;}
        @AuraEnabled 
        public list<AggregateResult> oppLines {get; set;}
    }
    @auraEnabled(cacheable=true)
    public static pricingWrapper getCurrentInfo(string prodId){
        date thirtyDaysAgo = Date.today() - 30; 
        pricingWrapper wrapBack = new pricingWrapper();
        //get product code
        string pc = [select id, ProductCode from product2 where id =: prodId and ProductClass = 'Simple'].ProductCode;
        //
        AggregateResult [] openOrder = [select avg(Unit_Price__c)openOrder from Open_Order_Detail__c where Product_Code__c = :pc];
        //sales details
        AggregateResult [] Sales = [select avg(Unit_Price__c)salesDoc from Sales_Doc_Detail__c where product__r.Product_Code__c = :pc 
                                    and Sales_Document__r.Doc_Date__c >=: thirtyDaysAgo and Sales_Document__r.Doc_Type__c = 'Invoice'];
        //get oppline items
        AggregateResult [] oppLineItems = [select avg(CPQ_Unit_Price__c)oppLineItem from OpportunityLineItem where Product2Id = :prodId 
                                    and LastModifiedDate >=: thirtyDaysAgo];
	//system.debug('pc '+ pc + ' Sales '+Sales); 
      //  system.debug('30 '+thirtyDaysAgo);
        wrapBack.open = openOrder;
        wrapBack.salesAVG = Sales;
        wrapBack.oppLines = oppLineItems; 
        return wrapBack;
    }
    ///TO SAVE PBE AND UPDATE PRODUCT2 AT ONE TIME. Records organized in lwc
    // @auraEnabled
// public static string savePBE(list<pricebookentry> entries, list<product2> products){
//     string messBack;
//     try{
//         if(entries.size()>0){
//             update entries;    
//         }
        
//         if(products.size()>0){
//             update products;
//         }
//         messBack = 'success'; 
//     }catch(exception e){
//         system.debug(e);
//       messBack = string.valueof(e);
//     }

//     return messBack; 
//}
}
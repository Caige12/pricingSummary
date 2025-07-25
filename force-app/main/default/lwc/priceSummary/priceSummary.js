import { LightningElement } from 'lwc';
import singlePicklist from '@salesforce/apex/lwcHelper.getPickListValues'; 
import LightningAlert from 'lightning/alert';
import AddPriceBoookEntry from 'c/addPriceBookEntry'; 
import savePBE from '@salesforce/apex/getPriceBooks_CR.savePBE';
//Old method Below Caige's Methos Above
//import savePBE from '@salesforce/apex/getPriceBooks.savePBE';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PriceSummary extends LightningElement {
    hideFilter = true;
    limitValue = 'no';
    orderByValue = 'none';
    product2Id;
    accountId;
    primaryCategory;   
    primCat = 'All';
    priceBookId; 
    priceBookDropStyle = 'slds-listbox slds-listbox_vertical slds-dropdown drop'

    field = 'UnitPrice'; 
    connectedCallback(){
        singlePicklist({objName:'Product2', fieldAPI:'Primary_Category__c'})
            .then((x)=>{
                this.primaryCategory = x; 
            })
    }
    async handleSearch(){
        let pass = this.valid()
         
        if(pass){
            const info =  new CustomEvent('searchvars',{
                detail:{
                    product2:this.product2Id,
                    accId: this.accountId,
                    priceField: this.field, 
                    limitAmount: this.limitValue === 'no'? 0 : Number(this.limitValue),
                    orderBy: this.orderByValue,
                    primCat: this.primCat,
                    pbId: this.priceBookId
                }
            })
            
            this.dispatchEvent(info);
        }else{
            await LightningAlert.open({
                message: 'Please select account or product!',
                theme: 'error', // a red theme intended for error states
                label: 'Error!', // this is the header text
            });
        }
    }

    // handleSearch(){
    //     console.log(`product2 ${this.product2Id}  accId: ${this.accountId} priceField: ${this.field}`)
    //     console.log(`limitAmount: ${this.limitValue} orderBy: ${this.orderByValue} primCat: ${this.primCat}`)
    // }
    showFilter(){
       this.hideFilter = !this.hideFilter ? true : false; 
    }
    //pricefields
    get priceFields(){
        return[
            {label:'List Price', value:'UnitPrice'},
            {label:'Cost', value:'Product_Cost__c'},
            {label:'Floor', value:'Floor_Price__c'},
            {label:'Floor Margin', value:'Floor_Margin__c'},
            {label:'Level 1', value:'Level_1_UserView__c'},
            {label: 'Level 1 Margin', value: 'Level_One_Margin__c'}, 
            {label:'Level 2', value:'Level_2_UserView__c'},
        ]
    }

    handlePriceField(evt){
        this.field = evt.detail.value; 
    }
    //order by
    get orderByOptions(){
        return[
            {label:'None', value:'none'},
            {label:'Highest Price', value:'DESC'},
            {label:'Lowest Price', value:'ASC'}
        ]
    }

    handleOrderBy(evt){
        this.orderByValue = evt.detail.value
    }
    
    //limit results
    get limitOptions() {
        let options = [];
        for(let i = 0; i<11; i++){
            let option = {label: i, value:`'${i}'`}
            options.push(option);
        }
        let noChoice = {label:'No', value:'no'}
        options.unshift(noChoice)
        return options; 
    }

    handleLimits(event){
        this.limitValue = event.detail.value; 
    }

    handleProduct(mess){
        this.product2Id = mess.detail; 

        // if(hideFilter){
        //     this.handleSearch()
        // }
    }
    async addProduct() {
        try {
            const result = await AddPriceBoookEntry.open({
                size: 'medium',
                description: 'Accessible description of modal\'s purpose',
                content: 'Passed into content api',
            });

            if (result === 'close' || !result) return;

            const recordInputs = result.map(draft => {
                return {
                    Pricebook2Id: draft.Pricebook2Id,
                    Product2Id: draft.Product2Id,
                    UseStandardPrice: false,
                    IsActive: draft.IsActive,
                    UnitPrice: draft.UnitPrice,
                    List_Margin__c: draft.List_Margin__c,
                    Hold_Margin__c: draft.Hold_Margin__c
                };
            });

            const res = await savePBE({ entries: recordInputs });

            if (res.status === 'success') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'All entries saved successfully.',
                        variant: 'success'
                    })
                );
            } else if (res.status === 'Catch Error') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Partial Save',
                        message: res.message,
                        variant: 'warning'
                    })
                );

            // Optional: Stretch Goal – show modal with res.errors[]
            // if (res.errors?.length) {
            //     await DuplicateModal.open({
            //         size: 'medium',
            //         description: 'Failed Entries',
            //         content: {
            //             duplicates: res.errors.map(e => ({ productName: '', errorMessage: e }))
            //         }
            //     });
            // }

            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: res.message || 'Unknown error occurred.',
                        variant: 'error'
                    })
                );
            }

            this.changesMade = false;
        } catch (error) {
            console.error(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Apex Error',
                    message: error.body?.message || 'Unknown Apex exception',
                    variant: 'error'
                })
            );
        }
    }
    
    handleClear(mess){
        let clearWhat = mess.detail; 
        switch(clearWhat){
            case 'product':
                this.product2Id = '';
                break;
            case 'account':
                this.accountId = '';
                break;
            case 'pricebook':
                this.priceBookId = '';
                break;
            default:
                console.log('not found')
        }
    }
    handleAccount(mess){
        this.accountId = mess.detail; 
        //need to get avaliable price books now for the account in the priceSummaryHolder
        if(this.accountId.length>1){
            const newAccount = new CustomEvent('newcust', {detail: this.accountId});
            this.dispatchEvent(newAccount);
        }
    }
    handlePriceBook(mess){
        //mess.id = id mess.name = pricebook name
        this.priceBookId = mess.detail.id; 
        
    }
    handlePrimCat(x){
        this.primCat = x.detail.value; 
    }
    valid(){
        let good = true; 
        if(this.accountId === undefined && 
           this.product2Id === undefined && 
           this.priceBookId === undefined){
            good = false; 
           }
           return good; 
    }

    getCounterUpdates(){
        const info =  new CustomEvent('counterinfo');
        this.dispatchEvent(info);
    }

}
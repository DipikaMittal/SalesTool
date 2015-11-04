/**
 * @author  Nicolas Palitzyne ~ nicolas.palitzyne@accenture.com
 * @date    11/05/2011
 * @details Controller for the Paginated List component.
 */
public class PaginatedList extends ComponentController
{
    /** Column headers */
    public string columnHeader1 {get{return returnHeader(0);}set;}
    public string columnHeader2 {get{return returnHeader(1);}set;}
    public string columnHeader3 {get{return returnHeader(2);}set;}
    public string columnHeader4 {get{return returnHeader(3);}set;}
    public string columnHeader5 {get{return returnHeader(4);}set;}
    public string columnHeader6 {get{return returnHeader(5);}set;}
    public string columnHeader7 {get{return returnHeader(6);}set;}
    public string columnHeader8 {get{return returnHeader(7);}set;}
    public string columnHeader9 {get{return returnHeader(8);}set;}
    public string columnHeader10{get{return returnHeader(9);}set;}
    
    /** Column sorting */
    public String col1Sort      {get{return columnSort.get('0');} set;}
    public String col2Sort      {get{return columnSort.get('1');} set;}
    public String col3Sort      {get{return columnSort.get('2');} set;}
    public String col4Sort      {get{return columnSort.get('3');} set;}
    public String col5Sort      {get{return columnSort.get('4');} set;}
    public String col6Sort      {get{return columnSort.get('5');} set;}                 
    public String col7Sort      {get{return columnSort.get('6');} set;}    
    public String col8Sort      {get{return columnSort.get('7');} set;}  
    public String col9Sort      {get{return columnSort.get('8');} set;}           
    public String col10Sort     {get{return columnSort.get('9');} set;}

    /**
     * (Attribute) List of columns to be displayed. In the
     * SelectOption instances, the value contains
     * the unique name of the field to be displayed
     * and the label the column header.
     */ 
    public List<SelectOption> columnList{get;set;}
    
    /** (Attribute) List of records to be displayed. */
    public List<sObject> displayRecordList{get;set;}

    /**
     * (Attribute) Set of existing records to use
     * in order to pre-default checkboxes for the
     * multi-select mode.
     */ 
    public Set<Object> existingRecords  {get;set;} 

    /**
     * (Attribute) List of fields to be used to 
     * build the unique key identifying a record
     * as already selected (some of them possibly have no
     * unique Salesforce ID as not inserted yet).
     */ 
    public List<String> FieldForKeyList{get;set;} 
    /**
     * List of results to be displayed in the component
     * as DataDisplayWrapper instances.
     */     
    public List<DataDisplayWrapper> searchResults{get;set;}   
    
    /** Columns used to sort the result */
    private String sortedBy;
    /** Order when sorting column, true for ascending, false for descending */
    private Boolean ascending = true;
    /** True if the list is sorted, false else */
    private boolean sortedList = true;
    /** True if the list is sorted by default, false if the user sorted it */   
    private boolean sortByDef= false;   
    /** Map of the column number (key) and the sorting status */    
    private Map<String, String> columnSort = new Map<String, String>();
    
    /** (Attribute) Number of records per page */
    public Integer recordsPerPage{get;set;}
    /** Current page number */
    public Integer pageNumber {get{if(pageNumber !=null){return pageNumber ;}else{return 1;}}set;}
    /** Capture directly the page number as a string from the UI */
    public String PageNumberString;
    
    /** Total number of pages */
    public Integer numberOfPages{get{if(numberOfPages!=null){return numberOfPages;}else{return 1;}}set;}  
    /** (Attribute) Sorting of columns is inactivated */
    public boolean noSorting{get;set;}
    /** The initialization has been performed */
    private boolean isInitialized = false;
    
    /** Map of fields to be displayed with their token. */
    public static Map<String, Schema.SObjectField> objFields = new Map<String, Schema.SObjectField>();
    /** Map of fields to be displayed with their type. */
    public static Map<String, Schema.DisplayType> objFieldTypes = new Map<String, Schema.DisplayType>();  
    
    /**
     * Inner class wrapping a sObject record with 
     * additional attributes and methods. A technical
     * object is used to display values in the table
     * according to the ColumnList attribute.
     */
    public class DataDisplayWrapper extends ComponentController {   
        /** Technical object record created in cache for display purposes only. */
        public TechObject__c displayedRecord{get; set;}
        /** Real record to be displayed. */
        public sObject realRecord{get;set;}
        /** Page number on which the record should appear. */
        public Integer pageNumber{get; set;}
        /** Set to true if the record is selected, false else (multi-select mode only). */
        public Boolean selected{get; set;}
        /** Disable the second commandlink. */
        public Boolean DisableAction2{get;set;}
        /** Disable the first commandlink. */
        public Boolean DisableAction{get;set;}        
        /** Key to search for already selected record for selection pre-defaulting. */
        public String KeyForExisting{get;set;}

        /** 
         * This method is called when the user clicks on the first commandLink, label
         * of which depends on the ActionLabel attribute, the actionNumber is then
         * set to 1 on the PageController super class and the performAction method is invoked.
         * 
         * The performAction method must be overriden in the page controller according to
         * the expected specific behavior.
         *
         * @return Pagereference The page returned by the method implemented on the page controller
         */
        public Pagereference action1() { 
           Pagereference result;
           pageController.ActionNumber = 1;     
           result = pageController.performAction(realRecord);
           return result;
        }
 
        /** 
         * This method is called when the user clicks on the second commandLink, label
         * of which depends on the Action2Label attribute, the actionNumber is then
         * set to 2 on the PageController super class and the performAction method is invoked.
         * 
         * The performAction method must be overriden in the page controller according to
         * the expected specific behavior.
         *
         * @return Pagereference The page returned by the method implemented on the page controller
         */ 
        public pagereference action2() {    
           Pagereference result;
           pageController.ActionNumber = 2;      
           result = pageController.performAction(realRecord);
           return result;
        }         
        
        /**
         * Convert a field into a string using
         * class attributes and the UtilityMethods .convertToString method
         *
         * @param   aFieldName  Name of the field to be converted into a string
         * @param   String      String value of the field
         */
        public String convertToString(String aFieldName) {
            String result;
            result = UtilityMethods.getStringFieldValue(realRecord, aFieldName);
            return result;
        }
        
        /** 
         * Constructor for the DataDisplayWrapper inner class.
         *
         * @param   aRecord         The record to be displayed
         * @param   pageNumber      Number of the page on which the record is displayed
         * @param   columnList      List of columns: value is the name of the field to be displayed
         *                          and the label the column header.
         * @param   pageController  controller of the parent page
         * @param   FieldForKeyList List of fields to be concatenated to form a unique key to identify
         *                          already selected records
         * @param   existingRecords Set of records already selected
         */
        public DataDisplayWrapper(sObject aRecord, Integer pageNumber, 
                                  List<SelectOption> columnList, PageController pageController,
                                  List<String> FieldForKeyList, 
                                  set<Object> existingRecords) {

            this.realRecord      = aRecord;
            this.pageNumber      = pageNumber;
            this.pageController  = pageController;
            this.displayedRecord = new TechObject__c();
            this.selected = false;
            
            // Build the unique key for this record
            if(existingRecords!=null && FieldForKeyList!=null) {             
                for(integer i=0; i < FieldForKeyList.size(); i++) {
                    if(i==0) {
                       KeyForExisting = convertToString(FieldForKeyList[i]);
                    }
                    else {
                       KeyForExisting += convertToString(FieldForKeyList[i]);
                    }
                }
                        
                // Check if this record is included in the set of existing records
                if(existingRecords.contains(KeyForExisting)) {
                    this.selected = true;
                    this.DisableAction = true;
                }               
            }
            
            // Array of fields of the technical object to be displayed 
            String[] disFieldList = new String[10];
            
            // Populate fields to be displayed
            for(Integer i=0; i<columnList.size(); i++) {
                disFieldList[i] = convertToString(columnList[i].getValue());
            }
            
            this.displayedRecord.field1__c  = disFieldList[0];
            this.displayedRecord.field2__c  = disFieldList[1];
            this.displayedRecord.field3__c  = disFieldList[2];
            this.displayedRecord.field4__c  = disFieldList[3];
            this.displayedRecord.field5__c  = disFieldList[4];
            this.displayedRecord.field6__c  = disFieldList[5];
            this.displayedRecord.field7__c  = disFieldList[6];
            this.displayedRecord.field8__c  = disFieldList[7];
            this.displayedRecord.field9__c  = disFieldList[8];
            this.displayedRecord.field10__c = disFieldList[9];
        }   
    } 

    /** 
     * Method returning the list of selected records.
     * @return  List<sObject>   The list of selected records.
     */
    public List<sObject> getSelectedObjects() {
    
        List<sObject> SelectedObjectList = new List<sObject>();
        for(DataDisplayWrapper DataWrapper:searchResults) {
                if(DataWrapper.selected==true) {
                    SelectedObjectList.add(DataWrapper.realRecord);
                }
        }
        
        return SelectedObjectList;
    }

    /** 
     * Dummy getter used to call the init method
     * after the constructor executes in order to
     * access values of the attributes.
     *
     * This is used as a workaround as it is not allowed to
     * trigger an action on component load.
     */        
    public string getInit() {
        Init();
        return null;
    }

    /** 
     * Initialization method which get token and types for fields to be displayed
     * and assign a page number to every record in the list.
     */
    public void Init() {
    
        // Map reference fields with the set of IDs for parent records 
        Map<String,Set<String>> referenceIDMap = new Map<String,Set<String>>();
        // Map reference fields with the name of the parent object
        Map<String, String> referenceObjMap    = new Map<String,String>();
        Set<Schema.sObjectType> objTypeSet     = new Set<Schema.sObjectType>();

        pageNumber    = 1; // Page number initialization
        numberOfPages = 1; // Total number of page initialization
        integer index = 0; // Index on the page (from 0 to recordPerPage)
        integer pages = 1; // Current page
        
        searchResults = new List<DataDisplayWrapper>();
        
        Schema.DescribeSObjectResult objDescribe;
        Schema.sObjectType objType;
        Schema.SObjectField field;
        Schema.DescribeFieldResult fieldDescribe;
        Schema.DisplayType fieldType;       

        if(displayRecordList!=null && displayRecordList.size()>0) {
            
            sObject sObj = displayRecordList[0];            
            objType      = sObj.getSObjectType();
            objTypeSet.add(objType);
            objDescribe  = objType.getdescribe();
            objFields    = objDescribe.fields.getMap();

            for(SelectOption selectValue:columnList)  {  
                String fieldName = selectValue.getvalue(); 
                field            = objFields.get(fieldName);
                
                if(field  == null) {
                    UtilityMethods.fieldTypeMap.put(fieldName, 'String');
                }
                else {

                    fieldDescribe    = field.getdescribe();
                    fieldType        = fieldDescribe.getType(); 
                    UtilityMethods.fieldTypeMap.put(fieldName, fieldType.name());   
                    Set<Schema.sObjectType> fieldObjTypeSet = new Set<Schema.sObjectType>();
                     
                    if(fieldType.name() == 'Reference') {
    
                        for(Schema.sObjectType refObjType:fieldDescribe.getReferenceTo()) {
                            objTypeSet.add(refObjType);
                            fieldObjTypeSet.add(refObjType);
                        }
    
                        for(Schema.sObjectType refObjType:fieldObjTypeSet) {
                            Schema.DescribeSObjectResult refObj = refObjType.getDescribe();
                            referenceObjMap.put(fieldName, refObj.getName());
                            referenceIDMap.put(fieldName, new set<String>());
                        }
                    }
                }
            }
            
            if(!objTypeSet.isEmpty()) {
                
                for(String refField:referenceObjMap.keySet()) {
                    String objName = referenceObjMap.get(refField);
                    
                    for(sObject record:displayRecordList) {
                        String refFieldvalue = String.valueOf(record.get(refField));
                        if(refFieldvalue != null) {
                            referenceIDMap.get(refField).add(refFieldvalue);
                        }
                    }   
                }
            }
            
            if(FieldForKeyList != null) {
                for(String selectValue:FieldForKeyList) {
                    field         = objFields.get(selectValue);
                    fieldDescribe = field.getdescribe();
                    fieldType     = fieldDescribe.getType(); 
                    objFieldTypes.put(selectValue,fieldType);          
                } 
            }           
            
            for(Integer recordSize=0; recordSize<displayRecordList.size(); recordSize++) {
                sObj = displayRecordList[recordSize];  
                searchResults.add(new DataDisplayWrapper(sObj,pages,columnList,pageController,FieldForKeyList,existingRecords));
                index++;
                
                // If the page is full, go to the next one
                if(index == recordsPerPage)  {
                    index=0;
                    pages++;
                }
                
                if(pages > 1) {
                    if(math.mod(displayRecordList.size(), recordsPerPage) == 0) {
                        numberOfPages = pages-1;
                    }
                    else {
                        numberOfPages = pages;
                    }
                }
                else {
                    numberOfPages = 1;
                }
            }
        }
    }  

    /** 
     * Method returning the Column header according to the column index
     * @param   i       The column index
     * @return  String  The column header to display
     */    
    public String returnHeader(Integer i) {
        String columnHeader;
        
        if(i<ColumnList.size()) {
            columnHeader = columnList[i].getLabel();
        }
        
        return columnHeader;
    }
    
    /**  Default constructor for the class. */          
    public PaginatedList() {
         columnList      = new List<SelectOption>(); 
         FieldForKeyList = new List<String>(); 
         searchResults   = new List<DataDisplayWrapper>();
         existingRecords = new Set<Object>();  
    }
    
    /**
     * This methods returns the list of DataDisplayWrapper
     * which are displayed on the screen - by selecting only
     * the ones with page number equal to the current page
     * number -
     * @return  List<DataDisplayWrapper>    The list of Wrappers for records 
     *                                      on the current page
     */
    public List<DataDisplayWrapper> getDisplaySearchResults() {  
        
        if(searchResults.isEmpty()) {
            Init();
        }
        
        List<DataDisplayWrapper> displayedRecords = new List<DataDisplayWrapper>();
        
        if(displayRecordList!=null && !displayRecordList.isEmpty())  {
            for(DataDisplayWrapper dataWrapper : searchResults)  {
                if(dataWrapper.pageNumber == pageNumber)  {
                    DisplayedRecords.add(dataWrapper);
                }
            }
        } 
        
        if(DisplayedRecords.isEmpty()) {
            displayRecordList = new List<sObject>();
        }

        return displayedRecords ;
    }
    
    /**
     * Display the start and end 
     * @return  List<DataDisplayWrapper>    The list of Wrappers for records 
     *                                      on the current page
     */
    public String getRecordsDisplay() {
        String results = '0';
        
        if( pageNumber==numberOfPages && !displayRecordList.isEmpty()) {
            results = ' ('+((pageNumber-1)*recordsPerPage+1) + ' - '+ displayRecordList.size()+') ';
        }
        else if(displayRecordList.size()>0) {
            results = ' ('+((pageNumber-1)*recordsPerPage+1) + ' - '+(pageNumber*recordsPerPage)+') ';
        }   

        return results;
    }  

    /** Setter for the PageNumberString */
    public void setPageNumberString(String input) {
        String result;
        String emailRegex = '^[1-9]\\d*$';
        System.debug('input = ' + input);
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        Matcher MyMatcher = MyPattern.matcher(input);
        
        if (MyMatcher.matches()) {
            System.debug('INPUT MATCHES ');
        
            Integer i = Integer.valueOf(input);
            System.debug('i = '+ i );
            if(i>numberOfPages) {
                pageNumber = numberOfPages;
            }
            else {
                pageNumber = i;
            }
        }
        else {
            pageNumber = 1;
        }
        
        PageNumberString = String.valueOf(pageNumber );
        System.debug('PageNumberString = '+pageNumber );

    }

     /** Getter for the PageNumberString */ 
    public String getPageNumberString() {
        System.debug('Page Number = ' + pageNumber);
        return String.valueOf(pageNumber);
    }
 

    /** Redirects to the first page */ 
    public void first() {
        if(pageNumber!=1) {
            pageNumber=1;
        }
    }
    
    /** Redirects to the last page */ 
    public void last() {
        if(pageNumber!=numberOfPages)
            pageNumber=numberOfPages;
    }  
    
    /** Redirects to the previous page */ 
    public void previous() {
        if(pageNumber!=1) {
            pageNumber--;
        }
    }   
    
    /** Redirects to the next page */ 
    public void next() {
        if(pageNumber<=numberOfPages) {
            pageNumber++;
            PageNumberString = String.valueOf(pageNumber );
        }
    }
    
    /** 
     * Sorts table by the selected column 
     */
    public void sortColumn() {
        if(noSorting != true) {
            columnSort = new Map<String, String>();
            sortByDef = true;
            
            for(Integer i=0; i<10;i++) {
                columnSort.put(String.valueOf(i),null);
            }
            
            String sortColumnNbr = system.currentpagereference().getparameters().get('sortColumn');
            setSortedBy(sortColumnNbr);
            displayRecordList = UtilityMethods.sortList(displayRecordList,columnList[Integer.ValueOf(sortColumnNbr)].getValue(), ascending);
            Init();
        }
    }
        
    /** 
     * Sets the sorting order for the selected column 
     * @string  value The number of the column to sort by    
     */
    private void setSortedBy(String value)  {
        if (sortedBy == value) {    
             ascending = !ascending;             
        } 
        else  {
            ascending = true;
        }
        columnSort.put(value, String.valueOf(ascending));
        sortedBy = value;
    }    
}
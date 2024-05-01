@IsTest
public class TestDataFactory {
    //Method to create Revenue Contract
    public static List<Revenue_Contract__c> createRevenueContract(Integer numOfRecords) {
        List<Revenue_Contract__c> lstRecords = new list<Revenue_Contract__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            lstRecords.add(new Revenue_Contract__c(
                Name = 'TestRevenueContract' + i, 
                Revenue_Contract_GUID__c = '123', 
                Bg_Run_ID__c = 'Test'
            ));
        }
        return lstRecords;
    }

    /*Method to create Test Revenue Contract Line Data*/
    public static List<Revenue_Contract_Line__c> createRevenueContractLine(integer numOfRecords) {
        List<Revenue_Contract_Line__c> lstRecords = new List<Revenue_Contract_Line__c>();
        for (integer i = 0; i < numOfRecords; i++) {
            lstRecords.add(new Revenue_Contract_Line__c(
                Line_Term__c = 3, 
                Terms__c = 12, 
                Bg_Run_ID__c = 'Test'
            ));// Name is not writeable
        }
        return lstRecords;
    }

    //method to create Revenue Contract Waterfall records
    public static List<Revenue_Contract_Waterfall__c> createRevenueContractWaterfall(Integer numOfRecords) {
        List<Revenue_Contract_Waterfall__c> lstRecords = new List<Revenue_Contract_Waterfall__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            lstRecords.add(new Revenue_Contract_Waterfall__c(
                Bg_Run_ID__c = 'Test'
            ));
        }
        return lstRecords;
    }

    //method to create Revenue Summary records
    public static List<Rev_Summary__c> createRevenueSummary(Integer numOfRecords) {
        List<Rev_Summary__c> lstRecords = new List<Rev_Summary__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            lstRecords.add(new Rev_Summary__c(
                Bg_Run_ID__c = 'Test'
            ));
        }
        return lstRecords;
    }

    //method to create Line Metric Dimension records
    public static List<Line_Met_Dimension__c> createLineMetricDimension(Integer numOfRecords) {
        List<Line_Met_Dimension__c> lstRecords = new List<Line_Met_Dimension__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            lstRecords.add(new Line_Met_Dimension__c(
                Bg_Run_ID__c = 'Test'
            ));
        }
        return lstRecords;
    }

}
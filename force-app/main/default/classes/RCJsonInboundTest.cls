@IsTest
public class RCJsonInboundTest {
    public static String assertMsg = 'Rest Response should not be empty';
    public static String restURI = '/services/apexrest/RCJson/';
    @TestSetup
    public static void setup() {
        List<Revenue_Contract__c> lstRevContracts = TestDataFactory.createRevenueContract(1);
        insert (lstRevContracts);
        List<Revenue_Contract_Line__c> lstLines = TestDataFactory.createRevenueContractLine(5);
        for (Revenue_Contract_Line__c line : lstLines) {
            line.Revenue_Contract_id__c = lstRevContracts[0].Id;
        }
        insert (lstLines);
        List<Revenue_Contract_Waterfall__c> lstWaterfalls = TestDataFactory.createRevenueContractWaterfall(5);
        for (Revenue_Contract_Waterfall__c waterfall : lstWaterfalls) {
            waterfall.Revenue_Contract_guid__c = lstRevContracts[0].Id;
        }
        insert (lstWaterfalls);
        List<Line_Met_Dimension__c> lstLineMetrics = TestDataFactory.createLineMetricDimension(5);
        for (Line_Met_Dimension__c lineMetric : lstLineMetrics) {
            lineMetric.Revenue_Contract_id__c = lstRevContracts[0].Id;
        }
        insert (lstLineMetrics);
        List<Rev_Summary__c> lstRevSummary = TestDataFactory.createRevenueSummary(5);
        for (Rev_Summary__c revSummary : lstRevSummary) {
            revSummary.Revenue_Contract_id__c = lstRevContracts[0].Id;
        }
        insert (lstRevSummary);
    }

    @IsTest
    static void testDeleteCase() {
        String body = '{"revenue_contract_id":["TestRevenueContract0"]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = restURI + '/1234567890';
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RCJsonInbound.doDelete();
        System.assert(res.responseBody != null, assertMsg);
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteCase2() {
        String body = '{"revenue_contract_id":["TestRevenueContract0"]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = restURI;
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RCJsonInbound.doDelete();
        System.assert(res.responseBody != null, assertMsg);
        Test.stopTest();
    }

}
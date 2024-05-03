@isTest
public class QueryServiceTest {
    @istest
    static void queryTest() {
        String nameSpaceString = Utility.getNameSpace();
        List<string> fieldList = new List<string>();
        String name = 'Name';
        fieldList.add(name);
        String revenue = 'Revenue_Contract__c';
        String revenueLine = 'Revenue_Contract_Lines__r';
        String filter = 'Name != null';
        Integer num = 2;
        String order = 'Line_Term__c ASC';
        Test.startTest();
        QueryService query = new QueryService(fieldList, revenue);
        query.setWhereClause(filter);
        query.setLimit(num);
        query.setOrderBy(order);
        String str = query.toSQL();
        system.assertEquals('SELECT Name FROM ' + nameSpaceString + 'Revenue_Contract__c WHERE Name != null ORDER BY Line_Term__c ASC LIMIT 2', str);
        Test.stopTest();
    }

    @isTest
    private static void testRelationshipQuery() {
        String nameSpaceString = Utility.getNameSpace();
        Test.startTest();
        QueryService q = new QueryService(new List<String>{ 'Billed_Amount__c', 'Carves_Currency_Code__c' }, 'Revenue_Contract__c', new Map<String, List<String>>{ 'Revenue_Contract_Lines__r' => new List<String>{ 'Above_Mid_point__c', 'Allocated_Amount__c' } });
        q.setWhereClause('Billed_Amount__c != null');
        String genQuery = q.toSQL();
        Test.stopTest();
        System.assertNotEquals(null, genQuery);
    }

}
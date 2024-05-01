public with sharing class Utility {
    public static Map<String, Map<String, Schema.SObjectField>> schemaFieldMap = new Map<String, Map<String, Schema.SObjectField>>();
    public static Map<String, Schema.SObjectType> schemaSObjectMap = new Map<String, Schema.SObjectType>();
    public static Map<String, Schema.DescribeSObjectResult> schemaSObjectResultMap = new Map<String, Schema.DescribeSObjectResult>();
    public static Map<Id, Map<String, List<String>>> mapFieldValues = new Map<Id, Map<String, List<String>>>();
    public static Map<Id, String> mapObjNameVal = new Map<Id, String>();
    public static List<String> appendFieldNameWithNamespace(List<String> fieldList, String sObejctName) {
        Map<String, String> localNameToApiNameMap = Utility.getLocalNameToApiNameMap(sObejctName);
        for (Integer counter = 0; counter < fieldList.size(); counter++) {
            String currentFieldName = fieldList[counter];
            if (localNameToApiNameMap.containsKey(currentFieldName)) {
                fieldList[counter] = localNameToApiNameMap.get(currentFieldName);
            }
        }
        return fieldList;
    }

    public static Map<String, String> getLocalNameToApiNameMap(String sObejctName) {
        Map<String, String> localNameToApiNameMap = new Map<String, String>();
        Map<String, Schema.SObjectField> objectFieldInfo = Utility.getFieldInfos(sObejctName);
        for (Schema.SObjectField sfield : objectFieldInfo.Values()) {
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            String apiName = dfield.getName();
            String localName = dfield.getLocalName();
            localNameToApiNameMap.put(localName, apiName);
        }
        return localNameToApiNameMap;
    }

    public static Map<String, Schema.SObjectField> getFieldInfos(String objectName) {
        String nameSpaceString = getNamespacePrefix();
        if (nameSpaceString != null) {
            List<String> objectNameSplits = objectName.split('__');
            if (objectNameSplits.size() == 2) {
                objectName = nameSpaceString + '__' + objectName;
            }
        }
        if (String.isNotBlank(objectName)) {
            return getFieldMapFromSObject(objectName);
        }
        return null;
    }

    /* Method to get the Sobject type information from Org
     *  @param String objectName - object api name
     */
    public static Schema.SObjectType getSObjectType(String objectName) {
        if (schemaSObjectMap.size() == 0 || !schemaSObjectMap.containsKey(objectName)) {
            schemaSObjectMap = Schema.getGlobalDescribe();
        }
        return schemaSObjectMap.get(objectName);
    }

    /* Method to get the SObject Result for sobject from Org
     *  @param String objectName - object api name
     */
    private static Schema.DescribeSObjectResult getSObjectResult(String objectName) {
        if (schemaSObjectResultMap.size() == 0 || !schemaSObjectResultMap.containsKey(objectName)) {
            schemaSObjectResultMap.put(objectName, getSObjectType(objectName).getDescribe());
        }
        return schemaSObjectResultMap.get(objectName);
    }

    /* Method to get the fields as a map from SObject
     *  @param String objectName - object api name
     */
    private static Map<String, Schema.SObjectField> getFieldMapFromSObject(String objectName) {
        if (!schemaFieldMap.containsKey(objectName)) {
            Schema.DescribeSObjectResult sobjectDetail = getSObjectResult(objectName);
            schemaFieldMap.put(objectName, sobjectDetail.fields.getMap());
        }
        return schemaFieldMap.get(objectName);
    }

    public static String getNameSpace() {
        String namespace = getNamespacePrefix();
        return namespace = namespace != null ? namespace + '__' : '';
    }

    private static string nameSpace;

    private static Boolean isNamespaceOrg = true;
    public static string getNamespacePrefix() {
        if (nameSpace == null && isNamespaceOrg) {
            List<ApexClass> apexClassList = [SELECT name, NamespacePrefix
                                             FROM ApexClass
                                             WHERE Name = 'RCJsonDeleteBatch'
                                             WITH SECURITY_ENFORCED];
            if (!apexClassList.isEmpty()) {
                nameSpace = apexClassList[0].NamespacePrefix;
                isNamespaceOrg = String.isNotBlank(nameSpace);
            }
        }
        return namespace;
    }

    public static void checkSOQLLimit() {
        try {
            Boolean boolResult = Limits.getLimitQueries() - Limits.getQueries() > 0;
            if (!boolResult) {
                throw new SalesforceLimitException('Too many SOQL Queries: ' + Limits.getLimitQueries());
            }
        } catch (SalesforceLimitException ex) {
            throw ex;
        }
    }

    public class SalesforceLimitException extends Exception {
    }

}
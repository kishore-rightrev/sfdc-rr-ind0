/**
 * @description: A generic class to dynamically query data.
 * @date : 10-Jan-2010
 */
public inherited sharing class QueryService {
    private List<String> listOfFields;

    private String sObejctName;

    private Integer limitRecord;

    private String whereClause;

    private String orderBy;

    private Map<String, List<String>> subObjectMaps;

    /**
     * @description: constructor for query Service
     * @arguments: listOfFields (List<String>)- fields to be queried,
     *             objectName(String) - object name to which fields belong to.
     */
    public QueryService(List<String> listOfFields, String objectName) {
        if (listOfFields.isEmpty()) {
            this.listOfFields = new List<String>{ 'Id' };
        } else {
            Set<String> setListOfFields = new Set<String>(listOfFields);
            this.listOfFields = new List<String>(setListOfFields);
        }
        if (String.isBlank(objectName)) {
            throw new QueryServiceException(Constants.INVALID_QUERY_OBJECT);
        } else {
            this.sObejctName = objectName;
        }
    }

    /**
     * @description: constructor overloaded for query Service
     * @arguments: listOfFields (List<String>)- fields to be queried,
     *             objectName(String) - object name to which fields belong to.
     *             subObjectMaps(Map<String, List<String>>)- map childRelationShipName to List of Field on the child object
     */
    public QueryService(List<String> listOfFields, String objectName, Map<String, List<String>> subObjectMaps) {
        if (listOfFields == null || listOfFields.isEmpty()) {
            this.listOfFields = new List<String>{ 'Id' };
        } else {
            Set<String> setListOfFields = new Set<String>(listOfFields);
            this.listOfFields = new List<String>(setListOfFields);
        }
        this.subObjectMaps = subObjectMaps;
        if (String.isBlank(objectName)) {
            throw new QueryServiceException(Constants.INVALID_QUERY_OBJECT);
        } else {
            this.sObejctName = objectName;
        }
    }

    /**
     * @description: setter to update whereClause
     * @argument: whereClause(String)- where clause of the query
     */
    public void setWhereClause(String whereClause) {
        if (String.isNotBlank(whereClause)) {
            this.whereClause = Constants.STRING_SPACE + whereClause;
        }
    }

    /**
     * @description: setter to update limit
     */
    public void setLimit(Integer limitQueryResult) {
        this.limitRecord = limitQueryResult;
    }

    /**
     * @description: setter to update orderBy
     */
    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
    }

    /**
     * @description: Generates the SOQL representation of the Query
     */
    public String toSQL() {
        Utility.checkSOQLLimit();
        String nameSpaceString = Utility.getNamespacePrefix();
        //String localSobjectName=sObejctName;
        String fullObjectName = sObejctName;
        if (nameSpaceString != null) {
            List<String> objectNameSplits = sObejctName.split('__');
            if (objectNameSplits.size() == 2) {
                fullObjectName = nameSpaceString + '__' + sObejctName;
            }
        }
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        DescribeSObjectResult objectDescribe = globalDescribe.get(fullObjectName).getDescribe();
        //sObejctName=objectDescribe.getName();
        listOfFields = Utility.appendFieldNameWithNamespace(listOfFields, fullObjectName);
        //Update field in the where clause with Namespace
        updateWhereClause(fullObjectName);
        //To remove duplicate fields
        Set<String> setListOfFields = new Set<String>(listOfFields);
        listOfFields = new List<String>(setListOfFields);
        String fieldToQuery = String.join(listOfFields, Constants.COMMA);
        fieldToQuery = fieldToQuery.removeEnd(Constants.COMMA);
        String soql = Constants.SOQL_SELECT + fieldToQuery + Constants.SOQL_FROM + fullObjectName;
        if (String.isNotBlank(whereClause)) {
            soql = soql + Constants.SOQL_WHERE + whereClause.trim();
        }
        if (String.isNotBlank(orderBy)) {
            Map<String, String> localNameToApiNameMap = Utility.getLocalNameToApiNameMap(fullObjectName);
            for (String localFieldName : localNameToApiNameMap.keySet()) {
                String namespacedFieldName = localNameToApiNameMap.get(localFieldName);
                Boolean hasComma = orderBy.contains(Constants.STRING_SPACE + localFieldName + ',');
                if ((orderBy.contains(Constants.STRING_SPACE + localFieldName + Constants.STRING_SPACE) || hasComma) && !orderBy.containsIgnoreCase(namespacedFieldName)) {
                    orderBy = orderBy.replace(Constants.STRING_SPACE + localFieldName + (hasComma ? ',' : Constants.STRING_SPACE), Constants.STRING_SPACE + namespacedFieldName + (hasComma ? ',' : Constants.STRING_SPACE));
                }
            }
            soql = soql + Constants.SOQL_ORDERBY + orderBy;
        }
        if (limitRecord != null) {
            soql = soql + Constants.SOQL_LIMIT + limitRecord;
        }
        return soql;
    }

    /**
     * @description: update the fieldname in the whereclause with namespace
     * @argument: sObjectName(string)- the parent object name
     */
    @testVisible
    private void updateWhereClause(String sObjectName) {
        if (this.whereClause != null) {
            Map<String, String> localNameToApiNameMap = Utility.getLocalNameToApiNameMap(sObjectName);
            for (String localFieldName : localNameToApiNameMap.keySet()) {
                String namespacedFieldName = localNameToApiNameMap.get(localFieldName);
                if (whereClause.contains(Constants.STRING_SPACE + localFieldName + Constants.STRING_SPACE) && !whereClause.containsIgnoreCase(namespacedFieldName)) {
                    whereClause = whereClause.replace(Constants.STRING_SPACE + localFieldName + Constants.STRING_SPACE, Constants.STRING_SPACE + namespacedFieldName + Constants.STRING_SPACE);
                }
            }
        }
    }

    /**
     * @description:generates the Sub Query String of the ChildObjct Map
     */
    public String getWhereClause() {
        return this.whereClause;
    }

    public class QueryServiceException extends Exception {
    }

}
public with sharing class RCJsonDeleteBatch implements Database.Batchable<SObject>, Database.stateful {
    private List<String> lstInputValues = new List<String>();
    private String strRunId;

    private String strObjName;

    public RCJsonDeleteBatch(List<String> lstInputs, String runId, String objName) {
        lstInputValues = lstInputs;
        strRunId = runId;
        strObjName = objName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getQuery(strObjName));
    }

    private String getQuery(String strObjectName) {
        QueryService qs = new QueryService(new List<String>{ Constants.FIELD_ID }, strObjectName);
        switch  on strObjectName {
            when 'Revenue_Contract_Waterfall__c' {
                qs.setWhereClause('Revenue_Contract_GUID__r.Name IN :lstInputValues AND Bg_Run_ID__c != :strRunId');
            }
            when 'Revenue_Contract_Line__c' {
                qs.setWhereClause('Revenue_Contract_id__r.Name IN :lstInputValues AND Bg_Run_ID__c != :strRunId');
            }
            when 'Rev_Summary__c' {
                qs.setWhereClause('Revenue_Contract_Id__r.Name IN :lstInputValues AND Bg_Run_ID__c != :strRunId');
            }
            when 'Line_Met_Dimension__c' {
                qs.setWhereClause('Revenue_Contract_ID__c IN :lstInputValues AND Bg_Run_ID__c != :strRunId');
            }
            when 'Revenue_Contract__c' {
                qs = new QueryService(new List<String>{ Constants.FIELD_ID, 'Name', 'RecordTypeId' }, strObjectName);
                qs.setWhereClause('Name IN : lstInputValues');
            }
        }
        return qs.toSQL();
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            switch  on strObjName {
                when 'Revenue_Contract__c' {
                    List<Revenue_Contract__c> lstRCLRecords = (List<Revenue_Contract__c>)scope;
                    List<Revenue_Contract__c> lstRecords = new List<Revenue_Contract__c>();
                    Map<String, Schema.RecordTypeInfo> mapRecordType = Schema.SObjectType.Revenue_Contract__c.getRecordTypeInfosByDeveloperName();
                    Id rcRecordTypeId = mapRecordType.get(Constants.RC).getRecordTypeId();
                    Id mjeRecordTypeId = mapRecordType.get('MJE_RC').getRecordTypeId();
                    for (Revenue_Contract__c record : lstRCLRecords) {
                        //recordType mapping from Name
                        Id correctRecordTypeId = record.Name.startsWith('RC-') ? rcRecordTypeId : mjeRecordTypeId;
                        if (record.RecordTypeId != correctRecordTypeId) {
                            record.RecordTypeId = correctRecordTypeId;
                            lstRecords.add(record);
                        }
                    }
                    update (lstRecords);
                }
                when else {
                    delete (scope);
                }
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, ExtendedStatus, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        if (job.NumberOfErrors > 0 || Test.isRunningTest()) {
            String strJobDetails = JSON.serialize(job);
            EmailWrapper emailWrap = new EmailWrapper();
            emailWrap.strProcessName = strObjName.capitalize();
            emailWrap.className = 'RCJsonDeleteBatch';
            emailWrap.message = strJobDetails;
            emailWrap.subject = 'RC DELETE';
            emailWrap.senderDisplayName = 'Batch Process';
            createAndSendEmail(emailWrap);
        }
    }

    public static Id executeBatch(List<String> lstInputValues, String strRunId, String strObjName) {
        RCJsonDeleteBatch batchClass = new RCJsonDeleteBatch(lstInputValues, strRunId, strObjName);
        String strQuery = batchClass.getQuery(strObjName);
        Integer intRecordSize = Database.countQuery(Constants.SOQL_SELECT + 'Count()' + Constants.SOQL_FROM + strQuery.substringAfter(Constants.SOQL_FROM));
        if (intRecordSize > 0) {
            return Database.executeBatch(batchClass, 2000);
        }
        return null;
    }
    
    private static void createAndSendEmail(EmailWrapper emailWrap) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (emailWrap != null) {
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body
                                           FROM EmailTemplate
                                           WHERE DeveloperName = 'RightRev_Post_Upgrade_Status'
                                           WITH SECURITY_ENFORCED
                                           LIMIT 1];
            String htmlBody = emailTemplate.HtmlValue;
            String strOrgId = UserInfo.getOrganizationId();
            String strOrgURL = URL.getOrgDomainURL().toExternalForm();
            String strOrgName = UserInfo.getOrganizationName();
            htmlBody = htmlBody.replace('methodName', emailWrap.strProcessName);
            htmlBody = htmlBody.replace('{!Organization.Id}', strOrgId);
            htmlBody = htmlBody.replace('className', emailWrap.className);
            htmlBody = htmlBody.replace('{!OrganizationURL}', strOrgURL);
            htmlBody = htmlBody.replace('{!Organization.Name}', strOrgName);
            htmlBody = htmlBody.replace('{!URL}', strOrgURL);
            htmlBody = htmlBody.replace('{!Message}', emailWrap.message);
            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('methodName', emailWrap.strProcessName);
            plainBody = plainBody.replace('{!Organization.Id}', strOrgId);
            plainBody = plainBody.replace('className', emailWrap.className);
            plainBody = plainBody.replace('{!Organization.Name}', strOrgName);
            plainBody = plainBody.replace('{!OrganizationURL}', strOrgURL);
            plainBody = plainBody.replace('{!Message}', emailWrap.message);
            mail.setToAddresses(new String[]{ Constants.INTEGRATION_USER_EMAIL });
            mail.setSenderDisplayName(emailWrap.senderDisplayName);
            mail.setSubject(emailWrap.subject);
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(plainBody);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail }, false);
        }
    }

    public class EmailWrapper {
        public String strDMLType;

        public String strProcessName;

        public String className;

        public String message;

        public String subject;

        public String senderDisplayName;

    }

}
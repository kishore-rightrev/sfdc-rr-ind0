@RestResource(urlMapping = '/RCJson/*')
global with sharing class RCJsonInbound {
    @HttpDelete
    global static void doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> mapResult = new Map<String, String>();
        try {
            String strRunId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            List<Id> lstJobIds = new List<Id>();
            Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            List<Object> lstRCs = (List<Object>)mapResponse.get('revenue_contract_id');
            List<String> lstRCNumbers = new List<String>();
            for (Object rcNumber : lstRCs) {
                lstRCNumbers.add((String) rcNumber);
            }
            lstJobIds.add(initiateDeleteBatch(lstRCNumbers, strRunId, 'Revenue_Contract__c'));
            lstJobIds.add(initiateDeleteBatch(lstRCNumbers, strRunId, 'Revenue_Contract_Waterfall__c'));
            lstJobIds.add(initiateDeleteBatch(lstRCNumbers, strRunId, 'Rev_Summary__c'));
            lstJobIds.add(initiateDeleteBatch(lstRCNumbers, strRunId, 'Line_Met_Dimension__c'));
            lstJobIds.add(initiateDeleteBatch(lstRCNumbers, strRunId, 'Revenue_Contract_Line__c'));
            mapResult.put('Status', 'OPERATION ENQUEUED');
            mapResult.put('JobIds', JSON.serialize(lstJobIds));
            res.statusCode = 200;
        } catch (Exception ex) {
            res.statusCode = 400;
            mapResult.put('Status', 'FAILED');
            mapResult.put('Details', ex.getMessage() + '' + ex.getStackTraceString());
        }
        res.responseBody = Blob.valueOf(JSON.serialize(mapResult));
    }

    private static Id initiateDeleteBatch(List<String> lstRCNumbers, String strRunId, String strObjName) {
        return RCJsonDeleteBatch.executeBatch(lstRCNumbers, strRunId, strObjName);
    }

}
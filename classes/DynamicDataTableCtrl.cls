/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for multiSelectLookup LWC
 * Created    : 03.22.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public without sharing class DynamicDataTableCtrl {
  private static final String FIELD_TYPE_REFERENCE = 'REFERENCE';
  /**
   * @description: get records based on target configs configured by admin
   * @param     objApiName      object API name configured in LWC target config
   * @param     fieldPaths      comma delimited string of field API names confiured in LWC target config
   * @param     whereClause     where clause configured in LWC target config
   * @return    recordWrappers  wrappers containing records and other info about the records
   */
  @AuraEnabled(cacheable=true)
  public static List<RecordDataModels.RecordWrapper> getRecordWrappers(
    String objApiName,
    String fieldPaths,
    String whereClause,
    Id recordId /* not directly read, but sometimes used for binding in query  */
  ) {
    try {
      List<String> fieldPathsToQuery = getFieldPathsToQuery(
        objApiName,
        fieldPaths
      );

      String queryStr =
        'SELECT ' +
        String.join(fieldPathsToQuery, ',') +
        ' FROM ' +
        objApiName +
        ' WHERE ' +
        whereClause;

      List<RecordDataModels.RecordWrapper> recordWrappers = new List<RecordDataModels.RecordWrapper>();
      for (SObject record : Database.query(queryStr)) {
        recordWrappers.add(
          new RecordDataModels.RecordWrapper(
            record,
            fieldPaths,
            DataTableUtils.getColumnPropertiesList(objApiName, fieldPaths)
          )
        );
      }
      return recordWrappers;
    } catch (exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        ', Stack Trace: ' +
        e.getStackTraceString()
      );
    }
  }

  /**
   * @description: get field paths to query for data table
   * @param   objApiName            object api name to query
   * @param   fieldPaths            comma delimited string of field paths specified in config
   * @return  fieldPathsToQuery     a list of field paths to query
   */
  private static List<String> getFieldPathsToQuery(
    String objApiName,
    String fieldPaths
  ) {
    List<String> fieldPathsToQuery = new List<String>();
    List<String> potentialRelFields = new List<String>(); // potential relationship fields (ex: AccountId)
    for (String fieldPath : fieldPaths.split(',')) {
      fieldPath = fieldPath.trim();
      if (!fieldPath.contains('.')) {
        potentialRelFields.add(fieldPath);
      }
      fieldPathsToQuery.add(fieldPath);
    }
    if (!potentialRelFields.isEmpty()) {
      for (String fieldApiName : potentialRelFields) {
        Schema.SObjectField field = FieldUtils.getFieldMap(objApiName)
          .get(fieldApiName);

        if (
          String.valueOf(field.getDescribe().getType()) == FIELD_TYPE_REFERENCE
        ) {
          String applicablePath;
          // standard fields:
          if (!fieldApiName.contains('__c')) {
            applicablePath = fieldApiName.removeEnd('Id');
          } else {
            // custom fields:
            applicablePath = fieldApiName.replace('__c', '__r');
          }

          String additionalPath = applicablePath + '.Name';
          if (!fieldPathsToQuery.contains(additionalPath)) {
            fieldPathsToQuery.add(additionalPath);
          }
        }
      }
    }
    return fieldPathsToQuery;
  }
}
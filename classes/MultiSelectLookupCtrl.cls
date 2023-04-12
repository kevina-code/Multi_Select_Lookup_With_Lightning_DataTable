/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for multiSelectLookup LWC
 * Created    : 03.22.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public class MultiSelectLookupCtrl {
  /**
   * @description: dynamically retrieve records based on user search input
   * @param   objApiName          object API name to query records for
   * @param   fieldPaths          string of field API names and field paths set in the target config (ex: Id, Name, Email, Phone, Account.Name)
   * @param   fieldPathsForSearch fields to based search off of (default is Name)
   * @param   value               user-entered value used to query records based on record name or other configured fields
   * @param   parentIdField       optional field to limit query results to child records belonging to the parent (ex: AccountId)
   * @param   recordId            optional parent record id to limit query results
   * @return  records             queried records based on search performed by user
   */
  @AuraEnabled(cacheable=true)
  public static List<RecordDataModels.RecordWrapper> retrieveSearchData(
    String objApiName,
    String fieldPaths,
    String fieldPathsForSearch,
    String value,
    List<String> selectedRecordIds,
    String whereClause,
    String recordId
  ) {
    List<RecordDataModels.RecordWrapper> recordWrappers = new List<RecordDataModels.RecordWrapper>();
    try {
      if (selectedRecordIds == null) {
        selectedRecordIds = new List<String>();
      }

      if (String.isNotEmpty(value)) {
        List<String> fieldPathsToQuery = getFieldPathsToQuery(
          objApiName,
          fieldPaths
        );

        String queryStr = buildQueryString(
          objApiName,
          fieldPathsToQuery,
          fieldPathsForSearch,
          value,
          selectedRecordIds,
          whereClause,
          recordId
        );

        for (SObject record : Database.Query(queryStr)) {
          recordWrappers.add(
            new RecordDataModels.RecordWrapper(
              record,
              fieldPaths,
              DataTableUtils.getColumnPropertiesList(objApiName, fieldPaths)
            )
          );
        }
      }
    } catch (Exception e) {
      String msg =
        'MultiSelectLookupCtrl.retrieveSearchData: ' +
        e.getMessage() +
        ', stack trace: ' +
        e.getStackTraceString();
      System.debug(msg);
      throw new AuraHandledException(msg);
    }
    return recordWrappers;
  }

  /**
   * @description: build dynamic query based on target configs/params and search value
   * @param   same parameters as retrieveSearchData method
   * @return  queryStr   the assembled query
   */
  private static String buildQueryString(
    String objApiName,
    List<String> fieldPathsToQuery,
    String fieldPathsForSearch,
    String value,
    List<String> selectedRecordIds,
    String whereClause,
    String recordId
  ) {
    String queryStr = 'SELECT Id, Name';
    if (fieldPathsToQuery != null) {
      for (String fieldPath : fieldPathsToQuery) {
        fieldPath = fieldPath.trim();
        if (
          fieldPath.toUpperCase() != 'ID' &&
          fieldPath.toUpperCase() != 'NAME'
        ) {
          queryStr += ', ' + fieldPath;
        }
      }
    }
    queryStr +=
      ' FROM ' +
      objApiName +
      ' WHERE (Name LIKE \'%' +
      value.trim() +
      '%\'';

    // loop through fields to bind to search
    for (String fieldPath : fieldPathsForSearch.split(',')) {
      if (
        fieldPath.trim().toUpperCase() != 'ID' &&
        fieldPath.trim().toUpperCase() != 'NAME'
      ) {
        queryStr += ' OR ' + fieldPath + ' LIKE \'%' + value.trim() + '%\'';
      }
    }
    queryStr += ')';

    queryStr += ' AND ID NOT IN :selectedRecordIds';

    if (whereClause != null && whereClause != '') {
      queryStr += ' AND ' + whereClause;
    }
    if (
      !whereClause.contains(' LIMIT ') &&
      !whereClause.contains(' limit ') &&
      !whereClause.contains(' Limit ')
    ) {
      queryStr += ' LIMIT 10';
    }
    return queryStr;
  }

  /**
   * @description: get field paths to query for data table\
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
      for (String field : potentialRelFields) {
        Map<String, Schema.SObjectField> fieldMap = FieldUtils.getDynamicDescribe(
            objApiName
          )
          .fields.GetMap();
        if (
          String.valueOf(fieldMap.get(field).getDescribe().getType()) ==
          'REFERENCE'
        ) {
          String relObjApiName = fieldMap
              .get(field)
              .getDescribe()
              .getReferenceTo()[0]
            .getDescribe()
            .getName();

          relObjApiName = relObjApiName.replace('__c', '__r');
          String additionalPath = relObjApiName + '.Name';
          if (!fieldPathsToQuery.contains(additionalPath)) {
            fieldPathsToQuery.add(additionalPath);
          }
        }
      }
    }
    return fieldPathsToQuery;
  }
}
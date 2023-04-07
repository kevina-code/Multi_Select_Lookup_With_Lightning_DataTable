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
        String queryStr = buildQueryString(
          objApiName,
          fieldPaths,
          fieldPathsForSearch,
          value,
          selectedRecordIds,
          whereClause,
<<<<<<< HEAD
          recordId
        );

        System.debug('queryStr: ' + queryStr);
=======
          recordId,
          recordLimit
        );
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
        for (SObject record : Database.Query(queryStr)) {
          recordWrappers.add(
            new RecordDataModels.RecordWrapper(
              record,
              fieldPaths,
<<<<<<< HEAD
              DataTableUtils.getColumnPropertiesList(objApiName, fieldPaths)
=======
              FieldUtils.getColumnHeaders(objApiName, fieldPaths)
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
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
    String fieldPaths,
    String fieldPathsForSearch,
    String value,
    List<String> selectedRecordIds,
    String whereClause,
<<<<<<< HEAD
    String recordId
=======
    String recordId,
    Integer recordLimit
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
  ) {
    String queryStr = 'SELECT Id, Name';
    if (fieldPaths != null) {
      for (String fieldPath : fieldPaths.split(',')) {
        if (
          fieldPath.trim().toUpperCase() != 'ID' &&
          fieldPath.trim().toUpperCase() != 'NAME'
        ) {
          queryStr += ', ' + fieldPath.trim();
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

<<<<<<< HEAD
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
=======
    // if whereClause specified in target config
    if (whereClause != null && whereClause != '') {
      queryStr += ' AND ' + whereClause;
    }
    queryStr +=
      ' AND ID NOT IN: selectedRecordIds ORDER BY CreatedDate DESC LIMIT ' +
      recordLimit;
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    return queryStr;
  }
}
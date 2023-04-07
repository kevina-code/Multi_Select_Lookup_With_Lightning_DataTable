/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for multiSelectLookup LWC
 * Created    : 03.22.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public class DynamicDataTableCtrl {
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
    Id recordId
  ) {
    try {
      String queryStr =
        'SELECT ' +
        fieldPaths +
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
   * data structure to store properties for the lightning data table
   */
  public class TableProperties {
    @AuraEnabled
    public List<String> columnHeaders = new List<String>();
    @AuraEnabled
    public List<String> fieldTypes = new List<String>();
    @AuraEnabled
    public List<Boolean> fieldUpdateables = new List<Boolean>();
  }

  /**
   * @description: get field properties for fields defined in config
   * @param   objApiName        object API Name
   * @param   fieldPaths        comma delimited string of field paths (ex: Id, Name, Phone, Email, Account.Name)
   * @param   columnHeaders     column headers (ex: Id, Full Name, Business Phone, Email, Account Name)
   * @return  TableProperties   table properties storing column headers, fieldTypes, fieldUpdateables
   */
  @AuraEnabled(cacheable=true)
  public static TableProperties getTableProperties(
    String objApiName,
    String fieldPaths
  ) {
    try {
      TableProperties tableProperties = new TableProperties();
      for (String fieldPath : fieldPaths.split(',')) {
        fieldPath = fieldPath.trim();
        DataTableUtils.ColumnProperties columnProperties = DataTableUtils.getColumnProperties(
          objApiName,
          fieldPath
        );
        tableProperties.columnHeaders.add(columnProperties.columnHeaderLabel);
        tableProperties.fieldTypes.add(columnProperties.fieldType);
        tableProperties.fieldUpdateables.add(columnProperties.isUpdateable);
      }

      return tableProperties;
    } catch (exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        ', Stack Trace: ' +
        e.getStackTraceString()
      );
    }
  }
}
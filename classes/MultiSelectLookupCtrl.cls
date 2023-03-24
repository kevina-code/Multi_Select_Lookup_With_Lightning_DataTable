/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for multiSelectLookup LWC
 * Created    : 03.22.2023
 */
public class MultiSelectLookupCtrl {
  /**
   * @description: dynamically retrieve field labels based on fieldApiNames target config value
   * @param   objApiName    object API name set in the target config (ex: Account)
   * @param   fieldApiNames string of field API names set in the target config (ex: Id, Name, AccountNumber)
   * @return  fieldLabels   a list of field labels based on fields configured in the fieldApiNames target config
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getFieldLabels(
    String objApiName,
    String fieldApiNames
  ) {
    try {
      Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
        .get(objApiName)
        .getDescribe()
        .fields.getMap();

      List<String> fieldLabels = new List<String>();
      for (String fieldApiName : fieldApiNames.split(',')) {
        Schema.DescribeFieldResult fieldResult = fieldMap.get(
            fieldApiName.trim()
          )
          .getDescribe();
        fieldLabels.add(fieldResult.getLabel());
      }
      return fieldLabels;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        ', Stack Trace: ' +
        e.getStackTraceString()
      );
    }
  }

  /**
   * @description: dynamically retrieve records based on user search input
   * @param   objApiName    object API name set in the target config (ex: Account)
   * @param   fieldApiNames string of field API names set in the target config (ex: Id, Name, AccountNumber)
   * @param   value         user-entered value used to query records based on record name
   * @return  records       queried records based on search performed by user
   */
  @AuraEnabled(cacheable=true)
  public static List<SObject> retrieveSearchData(
    String objApiName,
    String fieldApiNames,
    String value,
    List<String> selectedRecordIds
  ) {
    List<SObject> records = new List<SObject>();
    try {
      if (selectedRecordIds == null) {
        selectedRecordIds = new List<String>();
      }
      if (String.isNotEmpty(value)) {
        String query =
          'SELECT ' +
          fieldApiNames +
          ' FROM ' +
          objApiName +
          ' WHERE Name LIKE \'%' +
          value.trim() +
          '%\' and ID NOT IN: selectedRecordIds order by createdDate DESC LIMIT 10';
        System.debug('query: ' + query);
        for (SObject obj : Database.Query(query)) {
          records.add(obj);
        }
      }
    } catch (Exception e) {
      System.debug(
        'e: ' +
        e.getMessage() +
        ', stack trace: ' +
        e.getStackTraceString()
      );
    }
    return records;
  }
}

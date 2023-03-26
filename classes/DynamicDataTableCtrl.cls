/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for multiSelectLookup LWC
 * Created    : 03.22.2023
 */
public class DynamicDataTableCtrl {
  /**
   * @description: get records based on target configs configured by admin
   * @param     objApiName      object API name configured in LWC target config
   * @param     fieldApiNames   comma delimited string of field API names confiured in LWC target config
   * @param     whereClause     where clause configured in LWC target config
   * @return    list of queried SObject records
   */
  @AuraEnabled(cacheable=true)
  public static List<SObject> getRecords(
    String objApiName,
    String fieldApiNames,
    String whereClause,
    Id recordId
  ) {
    try {
      String queryStr =
        'SELECT ' +
        fieldApiNames +
        ' FROM ' +
        objApiName +
        ' WHERE ' +
        whereClause;
      return Database.query(queryStr);
    } catch (exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        ', Stack Trace: ' +
        e.getStackTraceString()
      );
    }
  }

  /**
   * @description: dynamically retrieve field labels
   * @param   objApiName    object API name set in the target config (ex: Account)
   * @param   fieldApiNames string of field API names set in the target config (ex: Id, Name, AccountNumber)
   * @return  a list of field labels
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getFieldLabels(
    String objApiName,
    String fieldApiNames
  ) {
    return getFieldInfo(objApiName, FieldApiNames, 'label');
  }

  /**
   * @description: dynamically retrieve field types
   * @param   objApiName    object API name set in the target config/LWC params (ex: Account)
   * @param   fieldApiNames string of field API names set in the target config/LWC params (ex: Id, Name, AccountNumber)
   * @return  a list of field types
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getFieldTypes(
    String objApiName,
    String fieldApiNames
  ) {
    return getFieldInfo(objApiName, FieldApiNames, 'type');
  }

  /**
   * @description: dynamically retrieve whether field is updateable or not
   * @param   objApiName    object API name set in the target config/LWC params (ex: Account)
   * @param   fieldApiNames string of field API names set in the target config/LWC params (ex: Id, Name, AccountNumber)
   * @return  a list of String booleans
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getFieldUpdateables(
    String objApiName,
    String fieldApiNames
  ) {
    return getFieldInfo(objApiName, FieldApiNames, 'updateable');
  }

  /**
   * @description: dynamically retrieve field labels or field types
   * @param   objApiName    object API name set in the target config (ex: Account)
   * @param   fieldApiNames string of field API names set in the target config (ex: Id, Name, AccountNumber)
   * @param   property      whether to retrieve field labels vs field types
   * @return  fieldLabels   a list of field labels based on fields configured in the fieldApiNames target config/LWC params
   */
  private static List<String> getFieldInfo(
    String objApiName,
    String fieldApiNames,
    String property /*label vs type*/
  ) {
    try {
      Map<String, Schema.SObjectField> fieldMap = ((SObject) Type.forName(
            'Schema',
            objApiName
          )
          .newInstance())
        .getSObjectType()
        .getDescribe()
        .fields.getMap();

      List<String> fieldInfos = new List<String>();
      for (String fieldApiName : fieldApiNames.split(',')) {
        Schema.DescribeFieldResult fieldResult = fieldMap.get(
            fieldApiName.trim()
          )
          .getDescribe();
        if (property == 'label') {
          fieldInfos.add(fieldResult.getLabel());
        } else if (property == 'type') {
          fieldInfos.add(String.valueOf(fieldResult.getType()));
        } else if (property == 'updateable') {
          fieldInfos.add(
            String.valueof(
              fieldMap.get(fieldApiName.trim()).getDescribe().isUpdateable()
            )
          );
        }
      }

      return fieldInfos;
    } catch (exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        ', Stack Trace: ' +
        e.getStackTraceString()
      );
    }
  }
}
/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : Utility class for parsing information about fields and field paths
 * Created      : 03.27.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public class FieldUtils {
  // map to cache describes in for better performance:
  private static Map<String, Schema.DescribeSObjectResult> objApiNameToDescribeMap = new Map<String, Schema.DescribeSObjectResult>();

  /**
   * @description: dynamically get the describe for a given object
   * @param   objApiName  object api name to get the describe for
   * @return  describe    the Schema.DescribeSObjectResult for the given object
   */
  public static Schema.DescribeSObjectResult getDynamicDescribe(
    String objApiName
  ) {
    Schema.DescribeSObjectResult describe = objApiNameToDescribeMap.get(
        objApiName
      ) == null
      ? ((SObject) Type.forName('Schema', objApiName).newInstance())
          .getSObjectType()
          .getDescribe()
      : objApiNameToDescribeMap.get(objApiName);
    objApiNameToDescribeMap.put(objApiName, describe);

    return describe;
  }

  /**
   * @description: given an SObject record, return a Schema.DescribeSObjectResult
   * @param   record    SObject record to get the describe for
   * @return  describe  the Schema.DescribeSObjectResult describe to return
   */
  public static Schema.DescribeSObjectResult getDynamicDescribe(
    SObject record
  ) {
    return getDynamicDescribe(String.valueOf(record.getSObjectType()));
  }

  /**
   * @description   Given an SObject name, return a Schema.SObjectField field map.
   * @param         objApiName   the name of the SObject in which to return a Schema.SObjectField field map for
   * @return        the Schema.SObjectField field map to return
   */
  public static Map<String, Schema.SObjectField> getFieldMap(
    String objApiName
  ) {
    return getDynamicDescribe(objApiName).fields.getMap();
  }

  /**
   * @description   Given an SObject record, return a Schema.SObjectField field map.
   * @param         record   SObject record to get the field map for
   * @return        the Schema.SObjectField field map to return
   */
  public static Map<String, Schema.SObjectField> getFieldMap(SObject record) {
    return getDynamicDescribe(record).fields.getMap();
  }

  /**
   * @description -> Method to get properties of a field set.
   * @usage example:
   *  List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('SBQQ__LineEditor','SBQQ__Quote__c');
   *  for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
   *      system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
   *      system.debug('Label ====>' + fieldSetMemberObj.getLabel());
   *      system.debug('Required ====>' + fieldSetMemberObj.getRequired());
   *      system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
   *      system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
   *  }
   *
   * @param   fieldSetName  name of field set you wish to get the properties (ex: fields) for
   * @param   objApiName    api name of object that field set resides on
   * @return  List<Schema.FieldSetMember -> field set properties to return.
   */
  public static List<Schema.FieldSetMember> readFieldSet(
    String fieldSetName,
    String objApiName
  ) {
    return getDynamicDescribe(objApiName)
      .FieldSets.getMap()
      .get(fieldSetName)
      .getFields();
  }

  /**
   * @description: get list of field API names to query, given a Schema.FieldSetMember list:
   * @param   fieldSetName  name of field set you wish to get the properties (ex: fields) for
   * @param   objApiName    api name of object that field set resides on
   * @return  objApiName a list of field API names parsed from the field set parameter
   */
  public static List<String> getFieldSetFieldAPINames(
    String fieldSetName,
    String objApiName
  ) {
    return getFieldSetFieldAPINames(readFieldSet(fieldSetName, objApiName));
  }

  /**
   * @description: get list of field API names to query, given a Schema.FieldSetMember list:
   * @param   fieldSetMemberList    a Schema.FieldSetMember list in which to parse the field API names from
   * @return  fieldSetFieldAPINames a list of field API names parsed from the field set parameter
   */
  public static List<String> getFieldSetFieldAPINames(
    List<Schema.FieldSetMember> fieldSetMemberList
  ) {
    Set<String> fieldSetFieldAPINamesSet = new Set<String>();
    for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
      fieldSetFieldAPINamesSet.add(fieldSetMemberObj.getFieldPath());
    }
    List<String> fieldSetFieldAPINames = new List<String>(
      fieldSetFieldAPINamesSet
    );
    return fieldSetFieldAPINames;
  }

  /**
   * @description: given an SObjectField (ex: Account.Name), determine if the field is createable
   * @param   sObjField   field to check if it is createable
   * @return  whether or not the field is createable
   */
  public static Boolean isFieldCreateable(Schema.SObjectField sObjField) {
    String objApiName = String.valueOf(
      sObjField.getDescribe().getsObjectType()
    );
    String fieldApiName = String.valueOf(
      sObjField.getDescribe().getSobjectField()
    );
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isCreateable();
  }

  /**
   * @description: given an SObjectField (ex: Account.Name), determine if the field is accessible
   * @param   sObjField   field to check if it is accessible
   * @return  whether or not the field is accessible
   */
  public static Boolean isFieldAccessible(Schema.SObjectField sObjField) {
    String objApiName = String.valueOf(
      sObjField.getDescribe().getsObjectType()
    );
    String fieldApiName = String.valueOf(
      sObjField.getDescribe().getSobjectField()
    );
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isAccessible();
  }

  /**
   * @description: given an SObjectField (ex: Account.Name), determine if the field is updateable
   * @param   sObjField   field to check if it is updateable
   * @return  whether or not the field is updateable
   */
  public static Boolean isFieldUpdateable(Schema.SObjectField sObjField) {
    String objApiName = String.valueOf(
      sObjField.getDescribe().getsObjectType()
    );
    String fieldApiName = String.valueOf(
      sObjField.getDescribe().getSobjectField()
    );
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isUpdateable();
  }

  /**
   * @description   Get all fields for an sobject as a list - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        allFields    : of all fields for the object;
   */
  public static List<String> getAllFieldsForSobj(String objApiName) {
    List<String> allFields = new List<String>(getFieldMap(objApiName).keySet());
    return allFields;
  }

  /**
   * @description   Get all fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all fields for the object delimited by commas
   */
  public static String getAllFieldsForSObjAsStr(String objApiName) {
    return String.join(getAllFieldsForSobj(objApiName), ', ');
  }

  /**
   * Method to return list of creatable fields for a given object.
   * @param String objApiName
   * @return List of creatable fields for a given SObject.
   */
  public static List<String> getCreatableFields(String objApiName) {
    // Get a map of field name and field token
    Map<String, Schema.SObjectField> fieldMap = getFieldMap(objApiName);

    List<String> creatableFields = new List<String>();
    if (fieldMap != null) {
      for (Schema.SObjectField field : fieldMap.values()) {
        if (isFieldCreateable(field)) {
          // field is updateable
          Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); // describe each field (fd)
          creatableFields.add(fieldDescribe.getName());
        }
      }
    }
    return creatableFields;
  }

  /**
   * Method to return list of accessible fields for a given object.
   * @param String objApiName
   * @return List of accessible fields for a given SObject.
   */
  public static List<String> getAccessibleFields(String objApiName) {
    // Get a map of field name and field token
    Map<String, Schema.SObjectField> fieldMap = getFieldMap(objApiName);

    List<String> accessibleFields = new List<String>();
    if (fieldMap != null) {
      for (Schema.SObjectField field : fieldMap.values()) {
        if (isFieldAccessible(field)) {
          // field is updateable
          Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); // describe each field (fd)
          accessibleFields.add(fieldDescribe.getName());
        }
      }
    }
    return accessibleFields;
  }

  /**
   * @description: get all updateable fields for an sobject as a list
   * @param  objApiName        API name of SObject to get updateable fields for
   * @return updateableFields   List of updateable fields for a given SObject.
   */
  public static List<String> getUpdateableFields(String objApiName) {
    // Get a map of field name and field token
    Map<String, Schema.SObjectField> fieldMap = getFieldMap(objApiName);

    List<String> updateableFields = new List<String>();
    if (fieldMap != null) {
      for (Schema.SObjectField field : fieldMap.values()) {
        if (isFieldUpdateable(field)) {
          // field is updateable
          Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); // describe each field (fd)
          updateableFields.add(fieldDescribe.getName());
        }
      }
    }
    return updateableFields;
  }

  /**
   * @description   Get all creatable fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all creatable fields for the object delimited by commas
   */
  public static String getAllCreatableFieldsAsStr(String objApiName) {
    return String.join(getCreatableFields(objApiName), ', ');
  }

  /**
   * @description   get all getAccessibleFields fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all getAccessibleFields fields for the object delimited by commas
   */
  public static String getAllAccessibleFieldsAsStr(String objApiName) {
    return String.join(getAccessibleFields(objApiName), ', ');
  }

  /**
   * @description   get all updateable fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all updateable fields for the object delimited by commas
   */
  public static String getAllUpdateableFieldsAsStr(String objApiName) {
    return String.join(getUpdateableFields(objApiName), ', ');
  }

  /**
   * @description   Get all fields for an sobject as a list, except those in the blacklist
   * @param         objApiName  : the object name to get the fields for
   * @param         blackList    : a list of fields to exclude
   * @return        List<String> : a list of all fields (except blacklist) for an SObject
   */
  public static List<String> getAllFieldsExceptBlacklist(
    String objApiName,
    List<String> blackList
  ) {
    Set<string> fields = new Set<String>(getAllFieldsForSobj(objApiName));
    for (String blackListedField : blackList) {
      if (fields.contains(blackListedField)) {
        fields.remove(blackListedField);
      } else if (fields.contains(blackListedField.toLowerCase())) {
        fields.remove(blackListedField.toLowerCase());
      }
    }
    return new List<String>(fields);
  }

  /**
   * @description   Get all fields (except blacklist) for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the SOBbject name to get the fields for
   * @param         blackList    : a list of fields to exclude
   * @return        String       : comma delimited string of all fields for the SObject (except blacklist)
   */
  public static String getAllFieldsExceptBlacklistAsStr(
    String objApiName,
    List<String> blackList
  ) {
    return String.join(
      getAllFieldsExceptBlacklist(objApiName, blackList),
      ', '
    );
  }

  /**
   * @description, for a given record and field path, parse the last sub object from the path
   *  For example: for an Contact record and Account.Owner.Name path, parse the User (Owner) record from the path
   * @param   record    record to parse last sub object from
   * @param   fieldpath the field path to use in the parsing (ex: Account.Owner.Name)
   */
  public static SObject parseLastSubObjectFromPath(
    SObject record,
    String fieldPath
  ) {
    SObject tempObj = record;
    String objsOnly = fieldPath.substringBeforeLast('.');
    for (String obj : objsOnly.split('\\.')) {
      try {
        tempObj = (SObject) tempObj.getSobject(obj);
      } catch (Exception e) {
        return null;
      }
    }
    return tempObj;
  }

  /**
   * @description:  method to parse field values from field references, even if in dot notation (ex: Account.Owner.Name)
   * @usage:        if I have a queried Task record where I queried Account.Owner.Name from the Task,
   *  if I pass in the Task record and 'Contract.Account.Name', this method will return the value stored in the 'Name'.
   *  Useful for when SObjectRecord.get(field) falls short since it can't do SObjectRecord.get(relationshipField.Field)
   * @param         record          : the record in which to parse the field reference from
   * @param         fieldPath       : the field reference in which to parse. Ex: 'Account.Owner.Name' will get the Name field value parsed
   * @return        fieldVal        : the String, Integer, Boolean, etc parsed value.
   */
  public static Object parseValueFromFieldPath(
    SObject record,
    String fieldPath
  ) {
    SObject tempObj = record;
    Object fieldVal;
    try {
      // If provided field is using dot notation, get nested object and field
      if (!fieldPath.contains('.')) {
        return record.get(fieldPath);
      } else {
        // ex: Account.Owner.Name, loop through Account.Owner
        for (
          String pathSegment : fieldPath.substringBeforeLast('.').split('\\.')
        ) {
          // dynamically accommodate for when path contains multiple nested SObjects (ex: Account.Owner.Name)
          tempObj = (SObject) tempObj.getSobject(pathSegment);
        }
        String fieldApiName = fieldPath.substringAfterLast('.');
        fieldVal = tempObj.get(fieldApiName);
      }
    } catch (Exception e) {
      return null;
    }

    return fieldVal;
  }
}
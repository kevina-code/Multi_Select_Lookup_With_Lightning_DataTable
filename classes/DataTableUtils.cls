/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : Utility class for parsing information for data tables
 * Created      : 03.27.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public without sharing class DataTableUtils {
  private static final String FIELD_TYPE_REFERENCE = 'REFERENCE';
  private static final String NAME = 'NAME';

  /**
   * inner class to store field path segment properties
   */
  public class ParsedPathProperties {
    public String segmentObjApiName;
    public String pathSegment;
    public String prevPathSegment;
    public String relObjApiName;
    public String segmentObjLabelName;
    public String segmentFieldApiName;
  }

  /**
   * @description: given an object API name and a field path in dot notation (ex: 'Account.Owner.UserRole.Name'),
   *   parse the obj/field api/label names from the path
   * @param   record     queried record to parse field path from
   * @param   fieldPath  field path to parse (ex: 'Account.Owner.UserRole.Name');
   * @return  pppList    data structure containing: prevPathSegment, segmentObjLabelName, objApiName, segmentFieldApiName, etc
   */
  public static List<ParsedPathProperties> parsePropertiesFromFieldPath(
    String objApiName,
    String fieldPath
  ) {
    fieldPath = fieldPath.trim();
    fieldPath = objApiName + '.' + fieldPath;
    String fieldPathDynamic = fieldPath;

    String currentObjApiName = objApiName;
    List<ParsedPathProperties> pppList = new List<ParsedPathProperties>();
    List<String> fieldPathSplit = fieldPath.split('\\.');
    for (Integer i = 0; i < fieldPathSplit.size(); i++) {
      if (i == fieldPathSplit.size() - 1) {
        break;
      } else if (i == 0) {
        // address the scenario of custom object at first segment:
        currentObjApiName = currentObjApiName.replace('__r', '__c');
      }

      ParsedPathProperties parsedPathProperties = new ParsedPathProperties();
      String prevPathSegment = fieldPathSplit[i].trim();
      parsedPathProperties.prevPathSegment = prevPathSegment;
      String nextPathSegment = fieldPathDynamic.substringAfter('.')
        .substringBefore('.');
      parsedPathProperties.pathSegment = nextPathSegment;

      fieldPathDynamic = fieldPathDynamic.remove(prevPathSegment + '.');
      String nextFieldApiName = nextPathSegment.replace('__r', '__c');
      // if standard id field
      if (!nextFieldApiName.contains('__c')) {
        if (i != fieldPathSplit.size() - 2) {
          nextFieldApiName += 'Id';
        }
      }

      Map<String, Schema.SObjectField> fieldMap = FieldUtils.getFieldMap(
        currentObjApiName
      );
      // get the case sensitive conforming version of the field:
      nextFieldApiName = fieldMap.get(nextFieldApiName).getDescribe().getName();

      String nextObjApiName = currentObjApiName;
      String relObjApiName;
      if (
        i != fieldPathSplit.size() - 2 ||
        (String.valueOf(
          fieldMap.get(nextFieldApiName).getDescribe().getType()
        ) == FIELD_TYPE_REFERENCE)
      ) {
        // for example, if path segment is 'Owner' from a path that is 'Account.Owner.Name',
        //  parsedObjApiName in this case would be 'User'
        String parsedObjApiName = fieldMap
            .get(nextFieldApiName)
            .getDescribe()
            .getReferenceTo()[0]
          .getDescribe()
          .getName();
        nextObjApiName = parsedObjApiName;
        relObjApiName = parsedObjApiName;
      }
      currentObjApiName = nextObjApiName;

      String label = nextFieldApiName.toUpperCase() != NAME
        ? fieldMap
            .get(nextFieldApiName)
            .getDescribe()
            .getLabel()
            .removeEnd(' ID')
        : nextFieldApiName;

      parsedPathProperties.segmentObjApiName = currentObjApiName;
      parsedPathProperties.prevPathSegment = prevPathSegment;
      parsedPathProperties.relObjApiName = relObjApiName;
      parsedPathProperties.segmentObjLabelName = label;
      parsedPathProperties.segmentFieldApiName = nextFieldApiName;
      pppList.add(parsedPathProperties);
    }
    return pppList;
  }

  /**
   * inner class to store table column properties
   */
  public class ColumnProperties {
    public String columnHeaderLabel;
    public String fieldType;
    public String fieldApiName;
    public Boolean isUpdateable = false;
    public Boolean isAccessible = false;
    public String relObjName; // relationship field api name (for AccountId, this would be 'Account')
    public String relObjApiName; // relationship field obj api name (for AccountId, this would be 'Account')
  }

  /**
   * @description: get column properties (column header label, fieldType, isupdateable, etc)
   *  for a particular field path
   * @param   objApiName            object API Name
   * @param   fieldPaths            Field API Names/paths to derive column headers from
   * @return  columnProperties      column properties for a given field path
   */
  public static ColumnProperties getColumnProperties(
    String objApiName,
    String fieldPath
  ) {
    fieldPath = fieldPath.trim();
    ColumnProperties columnProperties = new ColumnProperties();
    List<ParsedPathProperties> pppList = parsePropertiesFromFieldPath(
      objApiName,
      fieldPath
    );

    if (!fieldPath.contains('.')) {
      columnProperties.fieldApiName = pppList[0].segmentFieldApiName;
      columnProperties.columnHeaderLabel = pppList[0].segmentObjLabelName;
      columnProperties.fieldType = FieldUtils.getFieldType(
        objApiName,
        fieldPath
      );
      columnProperties.isAccessible = FieldUtils.isFieldAccessible(
        objApiName,
        fieldPath
      );
      columnProperties.isUpdateable = FieldUtils.isFieldUpdateable(
        objApiName,
        fieldPath
      );
      columnProperties.relObjName = columnProperties.columnHeaderLabel.removeEnd(
        ' ID'
      );
      columnProperties.relObjApiName = pppList[0].relObjApiName;
    } else {
      String columnHeaderLabel = '';
      for (ParsedPathProperties parsedPathProperties : pppList) {
        columnHeaderLabel += parsedPathProperties.segmentObjLabelName + ' ';
      }

      String subObjApiName = pppList[pppList.size() - 1].segmentObjApiName;
      String fieldApiName = pppList[pppList.size() - 1].segmentFieldApiName;
      columnProperties.columnHeaderLabel = columnHeaderLabel.trim();
      columnProperties.fieldType = FieldUtils.getFieldType(
        subObjApiName,
        fieldApiName
      );
      columnProperties.isAccessible = FieldUtils.isFieldAccessible(
        subObjApiName,
        fieldApiName
      );
    }
    return columnProperties;
  }

  /**
   * @description: get column headers for a given field path
   * @param   objApiName      object API Name
   * @param   fieldPaths      Field API Names/paths to derive column headers from
   * @return  columnHeaders   List of column headers (ex: 'Account Owner Role Name', 'Account Industry')
   */
  public static List<ColumnProperties> getColumnPropertiesList(
    String objApiName,
    String fieldPaths
  ) {
    List<ColumnProperties> columnPropertiesList = new List<ColumnProperties>();
    for (String fieldPath : fieldPaths.split(',')) {
      fieldPath = fieldPath.trim();
      ColumnProperties columnProperties = getColumnProperties(
        objApiName,
        fieldPath
      );
      columnPropertiesList.add(columnProperties);
    }
    return columnPropertiesList;
  }
}
/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : Utility class for parsing information for data tables
 * Created      : 03.27.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public without sharing class DataTableUtils {
  /**
   * inner class to store field path segment properties
   */
  public class ParsedPathProperties {
    public String pathSegment;
    public String objLabelName;
    public String objApiName;
    public String segmentFieldApiName;
  }

  /**
   * @description: given an object API name and a field path in dot notation (ex: 'Account.Owner.UserRole.Name'),
   *   parse the obj/field api/label names from the path
   * @param   record     queried record to parse field path from
   * @param   fieldPath  field path to parse (ex: 'Account.Owner.UserRole.Name');
   * @return  pppList    data structure containing: pathSegment, objLabelName, objApiName, segmentFieldApiName
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
      String pathSegment = fieldPathSplit[i];
      ParsedPathProperties.pathSegment = pathSegment;

      String nextPathSegment = fieldPathDynamic.substringAfter('.')
        .substringBefore('.');
      fieldPathDynamic = fieldPathDynamic.remove(pathSegment + '.');

      String nextFieldApiName = nextPathSegment.replace('__r', '__c');
      // if standard id field
      if (!nextFieldApiName.contains('__c')) {
        if (i != fieldPathSplit.size() - 2) {
          nextFieldApiName += 'Id';
        }
      }

      Schema.DescribeSObjectResult describe = FieldUtils.getDynamicDescribe(
        currentObjApiName
      );
      String nextObjApiName = currentObjApiName;
      if (i != fieldPathSplit.size() - 2) {
        nextObjApiName = describe
            .fields.getMap()
            .get(nextFieldApiName)
            .getDescribe()
            .getReferenceTo()[0]
          .getDescribe()
          .getName();
      }

      String label = nextFieldApiName.toUpperCase() != 'NAME'
        ? describe
            .fields.getMap()
            .get(nextFieldApiName)
            .getDescribe()
            .getLabel()
            .removeEnd(' ID')
        : nextFieldApiName;

      currentObjApiName = nextObjApiName;

      parsedPathProperties.pathSegment = pathSegment;
      parsedPathProperties.objLabelName = label;
      parsedPathProperties.objApiName = currentObjApiName;
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
    public Boolean isUpdateable = false;
  }

  /**
   * @description: get column properties (column header label, fieldType, isupdateable)
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
    if (!fieldPath.contains('.')) {
      Schema.DescribeSObjectResult describe = FieldUtils.getDynamicDescribe(
        objApiName
      );
      columnProperties.columnHeaderLabel = describe
        .fields.getMap()
        .get(fieldPath.trim())
        .getDescribe()
        .getLabel()
        .trim();
      columnProperties.fieldType = String.valueOf(
        describe.Fields.getMap().get(fieldPath).getDescribe().getType()
      );
      columnProperties.isUpdateable = describe.fields.getMap()
        .get(fieldPath)
        .getDescribe()
        .isUpdateable();
    } else {
      List<ParsedPathProperties> pppList = parsePropertiesFromFieldPath(
        objApiName,
        fieldPath
      );

      String columnHeaderLabel = '';
      for (ParsedPathProperties parsedPathProperties : pppList) {
        columnHeaderLabel += parsedPathProperties.objLabelName + ' ';
      }

      objApiName = pppList[pppList.size() - 1].objApiName;
      String fieldAPiName = pppList[pppList.size() - 1].segmentFieldApiName;
      columnProperties.columnHeaderLabel = columnHeaderLabel.trim();
      columnProperties.fieldType = String.valueOf(
        FieldUtils.getDynamicDescribe(objApiName)
          .Fields.getMap()
          .get(fieldAPiName)
          .getDescribe()
          .getType()
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
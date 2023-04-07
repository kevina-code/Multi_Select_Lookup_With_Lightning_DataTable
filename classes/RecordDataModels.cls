/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: Data Models for the following components
 *                  multi-select-lookup (LWC)
 *                  dynamic-data-table (LWC)
 * Created    : 03.30.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public class RecordDataModels {
  /**
   * wrapper class to store field properties for a record's fields
   */
  public class FieldProperty {
    @AuraEnabled
    public String columnHeader;
    @AuraEnabled
    public Object fieldValue;
    @AuraEnabled
    public String fieldApiName;
    @AuraEnabled
    public String fieldType;
    @AuraEnabled
    public String linkId;
    @AuraEnabled
    public String linkLabel;
  }

  /**
   * wrapper class to store additional properties alongside record
   */
  public class RecordWrapper {
    @AuraEnabled
    public SObject record;
    @AuraEnabled
    public String objName;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public Map<String, FieldProperty> fieldPropertyMap = new Map<String, FieldProperty>();

    public RecordWrapper(
      SObject recordParam,
      String fieldPaths,
      List<DataTableUtils.ColumnProperties> columnProperties
    ) {
      this.record = recordParam;

      List<String> fieldApiNameList = fieldPaths.split(',');
      for (String fieldPath : fieldApiNameList) {
        Integer index = fieldApiNameList.indexOf(fieldPath);
        fieldPath = fieldPath.trim();
        String columnHeader = columnProperties[index].columnHeaderLabel;
        FieldProperty fieldProperty = new FieldProperty();
        fieldProperty.columnHeader = columnHeader;
        fieldProperty.fieldType = columnProperties[index].fieldType;
        fieldProperty.linkLabel = columnHeader + '^_^' + index;
        if (!fieldPath.contains('.')) {
          fieldProperty.fieldValue = recordParam.get(fieldPath);
          fieldProperty.fieldApiName = fieldPath;
          if (fieldProperty.fieldValue instanceof Id) {
            fieldProperty.linkId = String.valueOf(fieldProperty.fieldValue);
          }
        } else {
          fieldProperty.fieldValue = FieldUtils.parseValueFromFieldPath(
            recordParam,
            fieldPath
          );
          fieldProperty.fieldApiName = fieldPath.substringAfterLast('.');
          String finalPathSegment = fieldPath.contains('.')
            ? fieldPath.substringAfterLast('.')
            : fieldPath;
          if (finalPathSegment.toUpperCase() == 'NAME') {
            fieldProperty.linkId = (Id) FieldUtils.parseLastSubObjectFromPath(
                recordParam,
                fieldPath
              )
              .get('Id');
          }
        }
        this.fieldPropertyMap.put(columnHeader, fieldProperty);
      }

      Schema.DescribeSObjectResult describe = FieldUtils.getDynamicDescribe(
        String.valueOf(recordParam.getSObjectType())
      );
      this.record = recordParam;
      this.objName = describe.getLabel();
      this.description = getDescriptionForPill(
        recordParam,
        fieldPaths,
        columnProperties,
        describe
      );
    }
  }

  /**
   * @desciption: get the description to apply multi-select-lookup lwc pill containers
   * @param     record          record to parse description from
   * @param     fieldPaths      field paths to parse from record
   * @param     columnProperties   object names to inject into description
   * @param     describe        DescribeSObjectResult for record
   * @return    description     description to inject into pill container
   */
  private static String getDescriptionForPill(
    SObject record,
    String fieldPaths,
    List<DataTableUtils.ColumnProperties> columnProperties,
    Schema.DescribeSObjectResult describe
  ) {
    String description = String.valueOf(record.get('Name'));
    if (fieldPaths != null) {
      List<String> fieldApiNameList = fieldPaths.split(',');
      for (String fieldPath : fieldApiNameList) {
        Integer index = fieldApiNameList.indexOf(fieldPath);
        fieldPath = fieldPath.trim();
        String columnHeader = columnProperties[index].columnHeaderLabel;
        if (
          fieldPath.toUpperCase() != 'ID' &&
          fieldPath.toUpperCase() != 'NAME'
        ) {
          description +=
            ' —	' +
            columnHeader +
            ': ' +
            String.valueOf(
              FieldUtils.parseValueFromFieldPath(record, fieldPath)
            );
        }
      }
    }
    return description;
  }
}
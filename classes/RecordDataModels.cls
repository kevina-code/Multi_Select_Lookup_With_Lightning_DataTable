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
    public Boolean isExtendedPath = false;
    @AuraEnabled
    public String fieldApiName;
    @AuraEnabled
    public String fieldType;
    @AuraEnabled
    public Boolean isAccessible = false;
    @AuraEnabled
    public Boolean isUpdateable = false;
    @AuraEnabled
    public String linkId;
    @AuraEnabled
    public String linkLabel;
    @AuraEnabled
    public String relObjName; // relationship object name (ex: Account)
    @AuraEnabled
    public String relObjApiName; // relationship object api name (ex: AccountId)
    @AuraEnabled
    public List<String> picklistLabels; // if the field is a picklist
    @AuraEnabled
    public List<String> picklistValues; // if the field is a picklist
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
      String objApiName = String.valueOf(recordParam.getSObjectType());
      List<String> fieldPathList = fieldPaths.split(',');
      for (String fieldPath : fieldPathList) {
        Integer index = fieldPathList.indexOf(fieldPath);
        fieldPath = fieldPath.trim();
        String columnHeader = columnProperties[index].columnHeaderLabel;
        FieldProperty fieldProperty = new FieldProperty();
        fieldProperty.columnHeader = columnHeader;
        fieldProperty.fieldType = columnProperties[index].fieldType;
        fieldProperty.isAccessible = columnProperties[index].isAccessible;
        fieldProperty.isUpdateable = columnProperties[index].isUpdateable;
        fieldProperty.linkLabel = columnHeader;

        if (!fieldPath.contains('.')) {
          if (fieldProperty.fieldType == 'REFERENCE') {
            fieldProperty.relObjName = columnProperties[index].relObjName;
            fieldProperty.relObjApiName = columnProperties[index].relObjApiName;
          } else if (fieldProperty.fieldType == 'PICKLIST') {
            fieldProperty.picklistLabels = FieldUtils.getPicklistLabels(
              objApiName,
              fieldPath
            );
            fieldProperty.picklistValues = FieldUtils.getPicklistValues(
              objApiName,
              fieldPath
            );
          }
          fieldProperty.fieldValue = recordParam.get(fieldPath);
          fieldProperty.fieldApiName = fieldPath;
          if (fieldProperty.fieldValue instanceof Id) {
            fieldProperty.linkId = String.valueOf(fieldProperty.fieldValue);
          }
        } else {
          fieldProperty.isExtendedPath = true;
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
        objApiName
      );
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
      List<String> fieldPathList = fieldPaths.split(',');
      for (String fieldPath : fieldPathList) {
        Integer index = fieldPathList.indexOf(fieldPath);
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
/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: Data Models for the following components
 *                  multi-select-lookup (LWC)
 *                  dynamic-data-table (LWC)
 * Created    : 03.30.2023
<<<<<<< HEAD
 *
 * Revisions:
 * Date : Name : Notes
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
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
<<<<<<< HEAD
    public String fieldApiName;
    @AuraEnabled
    public String fieldType;
    @AuraEnabled
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
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
<<<<<<< HEAD
      List<DataTableUtils.ColumnProperties> columnProperties
=======
      List<String> columnHeaders
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    ) {
      this.record = recordParam;

      List<String> fieldApiNameList = fieldPaths.split(',');
      for (String fieldPath : fieldApiNameList) {
        Integer index = fieldApiNameList.indexOf(fieldPath);
        fieldPath = fieldPath.trim();
<<<<<<< HEAD
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
=======
        String columnHeader = columnHeaders[index];
        FieldProperty fieldProperty = new FieldProperty();
        fieldProperty.columnHeader = columnHeader;
        fieldProperty.linkLabel = columnHeader + '^_^' + index;
        if (!fieldPath.contains('.')) {
          fieldProperty.fieldValue = recordParam.get(fieldPath);
        } else {
          fieldProperty.fieldValue = FieldUtils.parseFieldPathForSObject(
            recordParam,
            fieldPath
          );
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
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
<<<<<<< HEAD
        columnProperties,
=======
        columnHeaders,
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
        describe
      );
    }
  }

  /**
   * @desciption: get the description to apply multi-select-lookup lwc pill containers
   * @param     record          record to parse description from
   * @param     fieldPaths      field paths to parse from record
<<<<<<< HEAD
   * @param     columnProperties   object names to inject into description
=======
   * @param     columnHeaders   object names to inject into description
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
   * @param     describe        DescribeSObjectResult for record
   * @return    description     description to inject into pill container
   */
  private static String getDescriptionForPill(
    SObject record,
    String fieldPaths,
<<<<<<< HEAD
    List<DataTableUtils.ColumnProperties> columnProperties,
=======
    List<String> columnHeaders,
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    Schema.DescribeSObjectResult describe
  ) {
    String description = String.valueOf(record.get('Name'));
    if (fieldPaths != null) {
      List<String> fieldApiNameList = fieldPaths.split(',');
      for (String fieldPath : fieldApiNameList) {
        Integer index = fieldApiNameList.indexOf(fieldPath);
        fieldPath = fieldPath.trim();
<<<<<<< HEAD
        String columnHeader = columnProperties[index].columnHeaderLabel;
=======
        String columnHeader = columnHeaders[index];
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
        if (
          fieldPath.toUpperCase() != 'ID' &&
          fieldPath.toUpperCase() != 'NAME'
        ) {
          description +=
            ' —	' +
            columnHeader +
            ': ' +
            String.valueOf(
<<<<<<< HEAD
              FieldUtils.parseValueFromFieldPath(record, fieldPath)
=======
              FieldUtils.parseFieldPathForSObject(record, fieldPath)
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
            );
        }
      }
    }
    return description;
  }
}
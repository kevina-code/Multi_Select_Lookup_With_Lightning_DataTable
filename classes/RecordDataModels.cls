/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: Data Models for the following components
 *                  multi-select-lookup (LWC)
 *                  dynamic-data-table (LWC)
 * Created    : 03.30.2023
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
      List<String> columnHeaders
    ) {
      this.record = recordParam;

      List<String> fieldApiNameList = fieldPaths.split(',');
      for (String fieldPath : fieldApiNameList) {
        Integer index = fieldApiNameList.indexOf(fieldPath);
        fieldPath = fieldPath.trim();
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
        columnHeaders,
        describe
      );
    }
  }

  /**
   * @desciption: get the description to apply multi-select-lookup lwc pill containers
   * @param     record          record to parse description from
   * @param     fieldPaths      field paths to parse from record
   * @param     columnHeaders   object names to inject into description
   * @param     describe        DescribeSObjectResult for record
   * @return    description     description to inject into pill container
   */
  private static String getDescriptionForPill(
    SObject record,
    String fieldPaths,
    List<String> columnHeaders,
    Schema.DescribeSObjectResult describe
  ) {
    String description = String.valueOf(record.get('Name'));
    if (fieldPaths != null) {
      List<String> fieldApiNameList = fieldPaths.split(',');
      for (String fieldPath : fieldApiNameList) {
        Integer index = fieldApiNameList.indexOf(fieldPath);
        fieldPath = fieldPath.trim();
        String columnHeader = columnHeaders[index];
        if (
          fieldPath.toUpperCase() != 'ID' &&
          fieldPath.toUpperCase() != 'NAME'
        ) {
          description +=
            ' —	' +
            columnHeader +
            ': ' +
            String.valueOf(
              FieldUtils.parseFieldPathForSObject(record, fieldPath)
            );
        }
      }
    }
    return description;
  }
}
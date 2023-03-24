/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for multiSelectLookup LWC
 * Created    : 03.22.2023
 */
public class MultiSelectLookupCtrl {
  /**
   * @description: dynamically retrieve records based on user search input
   * @param   objApiName    object API name set in the target config (ex: Account)
   * @param   fieldApiNames string of field API names set in the target config (ex: Id, Name, AccountNumber)
   * @param   value         user-entered value used to query records based on record name
   * @return  records       queried records based on search performed by user
   */
  @AuraEnabled(cacheable=true)
  public static List<Wrapper> retrieveSearchData(
    String objApiName,
    String fieldApiNames,
    String value,
    List<String> selectedRecordIds
  ) {
    List<Wrapper> wrappers = new List<Wrapper>();
    try {
      if (selectedRecordIds == null) {
        selectedRecordIds = new List<String>();
      }
      if (String.isNotEmpty(value)) {
        String query = 'SELECT Id, Name';
        if (fieldApiNames != null) {
          for (String fieldApiName : fieldApiNames.split(',')) {
            if (
              fieldApiName.trim().toUpperCase() != 'ID' &&
              fieldApiName.trim().toUpperCase() != 'NAME'
            ) {
              query += ', ' + fieldApiName.trim();
            }
          }
        }
        query +=
          ' FROM ' +
          objApiName +
          ' WHERE (Name LIKE \'%' +
          value.trim() +
          '%\'';
        if (fieldApiNames == null) {
          query += ')';
        } else {
          for (String fieldApiName : fieldApiNames.split(',')) {
            if (
              fieldApiName.trim().toUpperCase() != 'ID' &&
              fieldApiName.trim().toUpperCase() != 'NAME'
            ) {
              query +=
                ' OR ' +
                fieldApiName +
                ' LIKE \'%' +
                value.trim() +
                '%\'';
            }
          }
          query += ')';
        }
        query += ' AND ID NOT IN: selectedRecordIds order by CreatedDate DESC LIMIT 10';
        for (SObject record : Database.Query(query)) {
          wrappers.add(new Wrapper(record, fieldApiNames));
        }
      }
    } catch (Exception e) {
      String msg =
        'MultiSelectLookupCtrl.retrieveSearchData: ' +
        e.getMessage() +
        ', stack trace: ' +
        e.getStackTraceString();
      System.debug(msg);
      throw new AuraHandledException(msg);
    }
    return wrappers;
  }

  /**
   * wrapper class to store additional properties alongside record
   */
  public class Wrapper {
    @AuraEnabled
    public SObject record;
    @AuraEnabled
    public String objName;
    @AuraEnabled
    public String description;

    public Wrapper(SObject record, String fieldApiNames) {
      Schema.DescribeSObjectResult describe = ((SObject) Type.forName(
            'Schema',
            String.valueOf(record.getSObjectType())
          )
          .newInstance())
        .getSObjectType()
        .getDescribe();
      this.record = record;
      this.objName = describe.getLabel();
      this.description = getDescription(record, fieldApiNames, describe);
    }

    public String getDescription(
      SObject record,
      String fieldApiNames,
      Schema.DescribeSObjectResult describe
    ) {
      String description = String.valueOf(record.get('Name'));
      if (fieldApiNames != null) {
        for (String fieldApiName : fieldApiNames.split(',')) {
          if (
            fieldApiName.trim().toUpperCase() != 'ID' &&
            fieldApiName.trim().toUpperCase() != 'NAME'
          ) {
            Schema.DescribeFieldResult fieldResult = describe.fields.getMap()
              .get(fieldApiName.trim())
              .getDescribe();
            description +=
              ' —	' +
              fieldResult.getLabel() +
              ': ' +
              String.valueOf(record.get(fieldApiName.trim()));
          }
        }
      }
      return description;
    }
  }
}
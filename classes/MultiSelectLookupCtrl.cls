/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for multiSelectLookup LWC
 * Created    : 03.22.2023
 */
public class MultiSelectLookupCtrl {
  /**
   * @description: dynamically retrieve records based on user search input
   * @param   objApiName    object API name to query records for
   * @param   fieldApiNames string of field API names set in the target config (ex: Id, Name, Email, Phone)
   * @param   value         user-entered value used to query records based on record name or other configured fields
   * @param   parentIdField optional field to limit query results to child records belonging to the parent (ex: AccountId)
   * @param   recordId      optional parent record id to limit query results
   * @return  records       queried records based on search performed by user
   */
  @AuraEnabled(cacheable=true)
  public static List<Wrapper> retrieveSearchData(
    String objApiName,
    String fieldApiNames,
    String value,
    List<String> selectedRecordIds,
    String whereClause,
    String recordId,
    Integer recordLimit
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

        // if whereClause specified in target config
        if (whereClause != null && whereClause != '') {
          query += ' AND ' + whereClause;
        }
        query +=
          ' AND ID NOT IN: selectedRecordIds ORDER BY CreatedDate DESC LIMIT ' +
          recordLimit;
        System.debug('query: ' + query);
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
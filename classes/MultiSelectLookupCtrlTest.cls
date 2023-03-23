/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: provides code coverage for the following classes: MultiSelectLookupCtrl
 * Created    : 03.22.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
@isTest
private class MultiSelectLookupCtrlTest {
  @isTest
  static void test_getFieldLabels() {
    Test.startTest();
    List<String> fieldLabels = MultiSelectLookupCtrl.getFieldLabels(
      'Account',
      'Id, Name, AccountNumber'
    );
    Test.stopTest();

    Assert.areEqual(fieldLabels[0], 'ID');
    Assert.areEqual(fieldLabels[1], 'Name');
    Assert.areEqual(fieldLabels[2], 'Account Number');
  }

  @isTest
  static void test_retrieveSearchData() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

    Test.startTest();
    List<SObject> records = MultiSelectLookupCtrl.retrieveSearchData(
      'Account',
      'Id, Name, AccountNumber',
      'ABC',
      new List<Id>{ accounts[1].Id }
    );
    Test.stopTest();

    Assert.isFalse(records.isEmpty());
    Assert.areEqual(records[0].get('Name'), 'ABC Corp');
  }
}
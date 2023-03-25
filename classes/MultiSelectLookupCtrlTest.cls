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
  static void test_retrieveSearchData() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

    Test.startTest();
    List<MultiSelectLookupCtrl.Wrapper> wrappers = MultiSelectLookupCtrl.retrieveSearchData(
      'Account',
      'Id, Name, AccountNumber',
      'ABC',
      new List<Id>{ accounts[1].Id },
      'Name != null',
      accounts[1].Id
    );
    Test.stopTest();

    Assert.isFalse(wrappers.isEmpty());
    Assert.areEqual(wrappers[0].record.get('Name'), 'ABC Corp');
  }
}

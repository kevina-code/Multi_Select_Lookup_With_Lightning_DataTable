/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: provides code coverage for the following classes: MultiSelectLookupCtrl
 * Created    : 03.22.2023
 *
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
    List<RecordDataModels.RecordWrapper> wrappers = MultiSelectLookupCtrl.retrieveSearchData(
      'Account' /* objApiName */,
      'Id, Name, AccountNumber' /* fieldPaths */,
      'Name' /* fieldPathsForSearch */,
      'ABC' /* value */,
      new List<Id>{ accounts[1].Id } /* selectedRecordIds */,
      'Name != null' /* whereClause */,
<<<<<<< HEAD
      accounts[1].Id /* recordId */
=======
      accounts[1].Id /* recordId */,
      10 /* recordLimit */
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    );
    Test.stopTest();

    Assert.isFalse(wrappers.isEmpty());
    Assert.areEqual(wrappers[0].record.get('Name'), 'ABC Corp');
  }

  @isTest
  static void test_retrieveSearchDataException() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

    Test.startTest();
    try {
      List<RecordDataModels.RecordWrapper> wrappers = MultiSelectLookupCtrl.retrieveSearchData(
        'Account' /* objApiName */,
        'Blah, Beep, Boop' /* fieldPaths */,
        'Name' /* fieldPathsForSearch */,
        'ABC' /* value */,
        new List<Id>{ accounts[1].Id } /* selectedRecordIds */,
        'Name != null' /* whereClause */,
<<<<<<< HEAD
        accounts[1].Id /* recordId */
=======
        accounts[1].Id /* recordId */,
        10 /* recordLimit */
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
      );
    } catch (Exception e) {
      Assert.isTrue(e.getMessage().contains('Script-thrown exception'));
    }
    Test.stopTest();
  }
}
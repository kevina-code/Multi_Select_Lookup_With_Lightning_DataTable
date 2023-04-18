/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: provides code coverage for the following classes: DynamicDataTableCtrl
 * Created    : 03.22.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
@isTest
private class DynamicDataTableCtrlTest {
  @isTest
  static void test_getRecordsWrappers() {
    List<Account> accounts = createTestAccounts();
    Contact contact = createTestContact(accounts[0]);
    insert contact;

    Test.startTest();
    List<RecordDataModels.RecordWrapper> contactsWrapper = DynamicDataTableCtrl.getRecordWrappers(
      'Contact' /* object api name */,
      'Id, Name, AccountId' /* field paths */,
      'Name != null' /* where clause */,
      accounts[0].Id /* record id */
    );
    Test.stopTest();

    Assert.isTrue(
      contactsWrapper[0].fieldPropertyMap.containsKey('Account'),
      'Expected fieldPropertyMap to contain the key/column header "Account"'
    );
    Assert.areEqual(
      contactsWrapper[0].fieldPropertyMap.get('Account').fieldType,
      'REFERENCE',
      'Expected the field type to be "REFERENCE"'
    );
  }

  @isTest
  static void test_getRecordsWrappersException() {
    List<Account> accounts = createTestAccounts();

    Test.startTest();
    try {
      List<RecordDataModels.RecordWrapper> acctsWrapper = DynamicDataTableCtrl.getRecordWrappers(
        'Account' /* object api name */,
        'Idddd, Nameeee, AccooountNumber, Owner.Name' /* field paths */,
        'Name != null' /* where clause */,
        accounts[0].Id /* record id */
      );
      Assert.fail('Illegal assignment exception Expected');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains('Script-thrown exception'),
        'Expected exception message to contain "Script-thrown exception"'
      );
    }
    Test.stopTest();
  }

  /** HELPER METHODS */
  private static List<Account> createTestAccounts() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'Test Account 1'));
    accounts.add(new Account(Name = 'Test Account 2'));
    accounts.add(new Account(Name = 'Test Account 3'));

    insert accounts;
    return accounts;
  }

  private static Contact createTestContact(Account account) {
    return new Contact(
      FirstName = account.Name,
      LastName = account.name,
      AccountId = account.Id,
      LeadSource = 'Web'
    );
  }
}
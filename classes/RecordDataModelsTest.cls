/**
 * Author      : Kevin Antonioli (braveitnow@pm.me)
 * Description : Provides test code coverage for RecordDataModels.cls
 * Created     : 03.30.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
@isTest
private class RecordDataModelsTest {
  @isTest
  static void test_RecordWrapper() {
    List<Account> accounts = createTestAccounts();

    List<Contact> contactList = new List<Contact>();
    Contact contact = createTestContact(accounts[0]);
    contact.Email = 'test@testtesttest.com';
    insert contact;

    contact = [
      SELECT Id, Name, Email, Account.Name
      FROM Contact
      WHERE Id = :contact.Id
    ];

    RecordDataModels.RecordWrapper recordWrappers = new RecordDataModels.RecordWrapper(
      contact,
      'Id, Name, Email, Account.Name',
      DataTableUtils.getColumnPropertiesList(
        'Contact',
        'Id, Name, Email, Account.Name'
      )
    );

    Assert.areEqual(
      recordWrappers.fieldPropertyMap.get('Account Name').columnHeader,
      'Account Name'
    );
    Assert.areEqual(
      recordWrappers.fieldPropertyMap.get('Account Name').fieldValue,
      'Test Account 1'
    );
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
      AccountId = account.Id
    );
  }
}
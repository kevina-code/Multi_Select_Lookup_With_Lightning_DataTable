/**
 * Author      : Kevin Antonioli (braveitnow@pm.me)
 * Description : Provides test code coverage for RecordDataModels.cls
 * Created     : 03.30.2023
<<<<<<< HEAD
 *
 * Revisions:
 * Date : Name : Notes
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
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

<<<<<<< HEAD
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
=======
    RecordDataModels.RecordWrapper recordWrapperS = new RecordDataModels.RecordWrapper(
      contact,
      'Id, Name, Email, Account.Name',
      new List<String>{ 'Id', 'Name', 'Email', 'Account Name' }
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    );
  }

  /** HELPER METHODS */
  private static List<Account> createTestAccounts() {
    List<Account> accounts = new List<Account>();
<<<<<<< HEAD
    accounts.add(new Account(Name = 'Test Account 1'));
    accounts.add(new Account(Name = 'Test Account 2'));
    accounts.add(new Account(Name = 'Test Account 3'));
=======
    accounts.add(new Account(Name = '1'));
    accounts.add(new Account(Name = '2'));
    accounts.add(new Account(Name = '3'));
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a

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
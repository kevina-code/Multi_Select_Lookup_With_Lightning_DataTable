/**
 * Author      : Kevin Antonioli (braveitnow@pm.me)
 * Description : Provides test code coverage for RecordDataModels.cls
 * Created     : 03.30.2023
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

    RecordDataModels.RecordWrapper recordWrapperS = new RecordDataModels.RecordWrapper(
      contact,
      'Id, Name, Email, Account.Name',
      new List<String>{ 'Id', 'Name', 'Email', 'Account Name' }
    );
  }

  /** HELPER METHODS */
  private static List<Account> createTestAccounts() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = '1'));
    accounts.add(new Account(Name = '2'));
    accounts.add(new Account(Name = '3'));

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
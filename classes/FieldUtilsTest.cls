/**
 * Author      : Kevin Antonioli (braveitnow@pm.me)
 * Description : Provides test code coverage for FieldUtils.cls
 * Created     : 03.29.2023
 */
@isTest
public class FieldUtilsTest {
  @isTest
  static void test_parseFieldPathForSObject() {
    List<Account> accounts = createTestAccounts();

    List<Contact> contactList = new List<Contact>();
    contactList.add(createTestContact(accounts[0]));
    insert contactList;

    Contact queriedContact = [
      SELECT Id, Name, Account.Name
      FROM Contact
      WHERE Id = :contactList[0].Id
      LIMIT 1
    ];

    Test.startTest();
    String accountName = (String) FieldUtils.parseFieldPathForSObject(
      queriedContact,
      'Account.Name'
    );
    String contactName = (String) FieldUtils.parseFieldPathForSObject(
      queriedContact,
      'Name'
    );
    Test.stopTest();

    Assert.areEqual(accountName, queriedContact.Account.Name);
    Assert.areEqual(contactName, queriedContact.Name);
  }

  @isTest
  static void test_parseLastSubObjectFromPath() {
    List<Account> accounts = createTestAccounts();
    accounts[0].OwnerId = UserInfo.getUserId();
    update accounts;

    List<Contact> contactList = new List<Contact>();
    contactList.add(createTestContact(accounts[0]));
    insert contactList;

    Contact contact = [
      SELECT Id, Account.Owner.Name
      FROM Contact
      WHERE Id IN :contactList
    ];
    SObject obj = FieldUtils.parseLastSubObjectFromPath(
      contact,
      'Account.Owner.Name'
    );

    Assert.isTrue(obj instanceof User);

    SObject obj2 = FieldUtils.parseLastSubObjectFromPath(
      contact,
      'Account.BLAH.name'
    );

    Assert.isNull(obj2);
  }

  @isTest
  static void test_parsePropertiesFromFieldPath() {
    String parsedPath = FieldUtils.parsePropertiesFromFieldPath(
        'Contact',
        'Account.Owner.UserRole.Name'
      )
      .parsedLabelNames;
    Assert.areEqual(parsedPath, 'Account Owner Role Name');

    List<String> parsedPath2 = FieldUtils.parsePropertiesFromFieldPath(
        'Contact',
        'Account.Owner.UserRole.Name'
      )
      .parsedObjApiNames;
    Assert.areEqual(parsedPath2[0], 'Account');
    Assert.areEqual(parsedPath2[1], 'User');
    Assert.areEqual(parsedPath2[2], 'UserRole');
  }

  @isTest
  static void test_getColumnHeaders() {
    List<String> columnHeaders = FieldUtils.getColumnHeaders(
      'Contact',
      'Account.Name, Account.Owner.Name, Account.Owner.UserRole.Name'
    );
    Assert.areEqual(columnHeaders[0], 'Account Name');
    Assert.areEqual(columnHeaders[1], 'Account Owner Name');
    Assert.areEqual(columnHeaders[2], 'Account Owner Role Name');
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
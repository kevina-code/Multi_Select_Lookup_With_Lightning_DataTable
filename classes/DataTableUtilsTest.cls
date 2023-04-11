/**
 * Author      : Kevin Antonioli (braveitnow@pm.me)
 * Description : Provides test code coverage for DataTableUtils.cls
 * Created     : 04.05.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
@isTest
private class DataTableUtilsTest {
  @isTest
  static void test_parsePropertiesFromFieldPath() {
    String parsedFromPath = DataTableUtils.parsePropertiesFromFieldPath(
        'Contact',
        'Account.Owner.UserRole.Name'
      )[2]
      .segmentObjLabelName;
    Assert.areEqual(
      parsedFromPath,
      'Role',
      'Expected parsedFromPath value to be "Role"'
    );
  }

  @isTest
  static void test_getColumnProperties() {
    String columnHeaderLabel = DataTableUtils.getColumnProperties(
        'Contact',
        'Account.Owner.UserRole.Name'
      )
      .columnHeaderLabel;
    String fieldType = DataTableUtils.getColumnProperties(
        'Contact',
        'Account.Owner.UserRole.Name'
      )
      .fieldType;
    Boolean isUpdateable = DataTableUtils.getColumnProperties(
        'Contact',
        'Account.Owner.UserRole.Name'
      )
      .isUpdateable;

    Assert.areEqual(
      columnHeaderLabel,
      'Account Owner Role Name',
      'Expected columnHeaderLabel value to be "Account Owner Role Name"'
    );
    Assert.areEqual(
      fieldType,
      'STRING',
      'Expected fieldType value to be "STRING"'
    );
    Assert.isFalse(isUpdateable, 'Expected isUpdateable value to be False');
  }

  @isTest
  static void test_getColumnPropertiesList() {
    List<DataTableUtils.ColumnProperties> columnProperties = DataTableUtils.getColumnPropertiesList(
      'Contact',
      'Account.Name, Account.Owner.Name, Account.Owner.UserRole.Name'
    );
    Assert.areEqual(
      columnProperties[0].columnHeaderLabel,
      'Account Name',
      'Expected the first columnProperties in the list to have a columnHeaderLabel of "Account Name"'
    );
    Assert.areEqual(
      columnProperties[1].columnHeaderLabel,
      'Account Owner Name',
      'Expected the second columnProperties in the list to have a columnHeaderLabel of "Account Owner Name"'
    );
    Assert.areEqual(
      columnProperties[2].columnHeaderLabel,
      'Account Owner Role Name',
      'Expected the third columnProperties in the list to have a columnHeaderLabel of "Account Owner Role Name"'
    );
    Assert.areEqual(
      columnProperties[0].fieldType,
      'STRING',
      'Expected the first columnProperties in the list to have a fieldType of "STRING"'
    );
    Assert.areEqual(
      columnProperties[1].fieldType,
      'STRING',
      'Expected the second columnProperties in the list to have a fieldType of "STRING"'
    );
    Assert.areEqual(
      columnProperties[2].fieldType,
      'STRING',
      'Expected the third columnProperties in the list to have a fieldType of "STRING"'
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
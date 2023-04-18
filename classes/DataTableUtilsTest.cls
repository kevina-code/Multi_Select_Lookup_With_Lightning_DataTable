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
    DatatableUtils.ParsedPathProperties ppp = DataTableUtils.parsePropertiesFromFieldPath(
      'Contact',
      'Account.Owner.UserRole.Name'
    )[2];

    Assert.areEqual(
      ppp.prevPathSegment,
      'Owner',
      'Expected prevPathSegment value to be "Owner"'
    );
    Assert.areEqual(
      ppp.pathSegment,
      'UserRole',
      'Expected pathSegment value to be "UserRole"'
    );
    Assert.areEqual(
      ppp.segmentObjLabelName,
      'Role',
      'Expected the segmentObjLabelName value to be "Role"'
    );
    Assert.areEqual(
      ppp.segmentFieldApiName,
      'UserRoleId',
      'Expected segmentFieldApiName value to be "UserRoleId"'
    );
    Assert.areEqual(
      ppp.segmentObjApiName,
      'UserRole',
      'Expected segmentObjApiName value to be "UserRole"'
    );

    DatatableUtils.ParsedPathProperties ppp2 = DataTableUtils.parsePropertiesFromFieldPath(
      'Contact',
      'AccountId'
    )[0];

    Assert.areEqual(
      ppp2.prevPathSegment,
      'Contact',
      'Expected prevPathSegment value to be "Contact"'
    );
    Assert.areEqual(
      ppp2.segmentObjLabelName,
      'Account',
      'Expected the segmentObjLabelName value to be "Account"'
    );
    Assert.areEqual(
      ppp2.segmentFieldApiName,
      'AccountId',
      'Expected segmentFieldApiName value to be "AccountId"'
    );
    Assert.areEqual(
      ppp2.segmentObjApiName,
      'Account',
      'Expected segmentObjApiName value to be "Account"'
    );
  }

  @isTest
  static void test_getColumnProperties() {
    DataTableUtils.ColumnProperties columnProperties = DataTableUtils.getColumnProperties(
      'Contact',
      'Account.Owner.UserRole.Name'
    );

    Assert.areEqual(
      columnProperties.columnHeaderLabel,
      'Account Owner Role Name',
      'Expected columnHeaderLabel value to be "Account Owner Role Name"'
    );
    Assert.areEqual(
      columnProperties.fieldType,
      'STRING',
      'Expected fieldType value to be "STRING"'
    );
    Assert.isFalse(
      columnProperties.isUpdateable,
      'Expected isUpdateable value to be False'
    );

    DataTableUtils.ColumnProperties columnProperties2 = DataTableUtils.getColumnProperties(
      'Contact',
      'AccountId'
    );

    Assert.areEqual(
      columnProperties2.columnHeaderLabel,
      'Account',
      'Expected columnHeaderLabel value to be "Account"'
    );
    Assert.areEqual(
      columnProperties2.fieldType,
      'REFERENCE',
      'Expected fieldType value to be "REFERENCE"'
    );
    Assert.isTrue(
      columnProperties2.isUpdateable,
      'Expected isUpdateable value to be true'
    );
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
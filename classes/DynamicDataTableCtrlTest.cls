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
  static void test_getRecords() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

    Test.startTest();
    List<SObject> accts = DynamicDataTableCtrl.getRecords(
      'Account',
      'Id, Name, AccountNumber',
      'Name != null',
      accounts[0].Id
    );
    Test.stopTest();

    Assert.isFalse(accts.isEmpty());
  }

  @isTest
  static void test_getFieldInfo() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

    Test.startTest();
    List<String> fieldLabels = DynamicDataTableCtrl.getFieldLabels(
      'Account',
      'Id, Name, AccountNumber'
    );
    List<String> fieldTypes = DynamicDataTableCtrl.getFieldTypes(
      'Account',
      'Id, Name, AccountNumber'
    );
    List<String> fieldUpdateables = DynamicDataTableCtrl.getFieldUpdateables(
      'Account',
      'Id, Name, AccountNumber'
    );
    Test.stopTest();

    Assert.areEqual(fieldLabels[1], 'Account Name');
    Assert.areEqual(fieldLabels[2], 'Account Number');
    Assert.areEqual(fieldTypes[1], 'STRING');
    Assert.areEqual(fieldTypes[2], 'STRING');
    Assert.areEqual(fieldUpdateables[1], 'true');
    Assert.areEqual(fieldUpdateables[2], 'true');
  }
}

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
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

    Test.startTest();
    List<RecordDataModels.RecordWrapper> acctsWrapper = DynamicDataTableCtrl.getRecordWrappers(
      'Account' /* object api name */,
      'Id, Name, AccountNumber, Owner.Name' /* field paths */,
      'Name != null' /* where clause */,
      accounts[0].Id /* record id */
    );
    Test.stopTest();

    Assert.isNotNull(acctsWrapper, 'Expected acctsWrapper not to be null');
  }
  @isTest
  static void test_getRecordsWrappersException() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

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

  @isTest
  static void test_getFieldInfo() {
    Test.startTest();
    DynamicDataTableCtrl.TableProperties tableProps1 = DynamicDataTableCtrl.getTableProperties(
      'Account',
      'Id, Name, AccountNumber, Owner.Name'
    );
    DynamicDataTableCtrl.TableProperties tableProps2 = DynamicDataTableCtrl.getTableProperties(
      'Contact',
      'Id, Name, Phone, Email, Account.Name'
    );
    Test.stopTest();

    Assert.areEqual(
      tableProps1.columnHeaders[1],
      'Name',
      'Expected columnHeaders[1] to be equal to "Name"'
    );
    Assert.areEqual(
      tableProps1.columnHeaders[2],
      'Account Number',
      'Expected columnHeaders[2] to be equal to "Account Number"'
    );
    Assert.areEqual(
      tableProps1.columnHeaders[3],
      'Owner Name',
      'Expected columnHeaders[3] to be equal to "Owner Name"'
    );
    Assert.areEqual(
      tableProps1.fieldTypes[1],
      'STRING',
      'Expected fieldTypes[1] to be equal to "STRING"'
    );
    Assert.areEqual(
      tableProps1.fieldTypes[2],
      'STRING',
      'Expected fieldTypes[2] to be equal to "STRING"'
    );
    Assert.isTrue(
      tableProps1.fieldUpdateables[1],
      'Expected fieldUpdateables[1] to be equal to True'
    );
    Assert.isTrue(
      tableProps1.fieldUpdateables[2],
      'Expected fieldUpdateables[2] to be equal to True'
    );

    Assert.areEqual(
      tableProps2.columnHeaders[1],
      'Name',
      'Expected columnHeaders[1] to be equal to "Name"'
    );
    Assert.areEqual(
      tableProps2.columnHeaders[2],
      'Business Phone',
      'Expected columnHeaders[2] to be equal to "Business Phone"'
    );
    Assert.areEqual(
      tableProps2.columnHeaders[4],
      'Account Name',
      'Expected columnHeaders[4] to be equal to "Account Name"'
    );
    Assert.areEqual(
      tableProps2.fieldTypes[1],
      'STRING',
      'Expected fieldTypes[1] to be equal to "STRING"'
    );
    Assert.areEqual(
      tableProps2.fieldTypes[2],
      'PHONE',
      'Expected fieldTypes[2] to be equal to "PHONE"'
    );
    Assert.isFalse(
      tableProps2.fieldUpdateables[1],
      'Expected fieldUpdateables[1] to be equal to False'
    );
    Assert.isTrue(
      tableProps2.fieldUpdateables[2],
      'Expected fieldUpdateables[2] to be equal to True'
    );
  }

  @isTest
  static void test_getFieldInfoException() {
    try {
      Test.startTest();
      DynamicDataTableCtrl.TableProperties tableProps1 = DynamicDataTableCtrl.getTableProperties(
        'Account',
        'Id, Nameeeeee, AccountNumber, Owner.Name'
      );
      Test.stopTest();
      Assert.fail('Illegal assignment exception Expected');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains('Script-thrown exception'),
        'Expected exception message to contain "Script-thrown exception"'
      );
    }
  }
}
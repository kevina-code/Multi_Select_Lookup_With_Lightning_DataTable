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
<<<<<<< HEAD
      'Account' /* object api name */,
      'Id, Name, AccountNumber, Owner.Name' /* field paths */,
      'Name != null' /* where clause */,
      accounts[0].Id /* record id */
=======
      'Account',
      'Id, Name, AccountNumber, Owner.Name',
      'Name != null',
      accounts[0].Id
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    );
    Test.stopTest();

    Assert.isFalse(acctsWrapper == null);
<<<<<<< HEAD
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
    } catch (Exception e) {
      Assert.isTrue(e.getMessage().contains('Script-thrown exception'));
    }
    Test.stopTest();
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
  }
  @isTest
<<<<<<< HEAD
  static void test_getFieldInfo() {
    Test.startTest();
=======
  static void test_getRecordsWrappersException() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = 'ABC Corp'));
    accounts.add(new Account(Name = 'DEF Corp'));
    accounts.add(new Account(Name = 'XYZ Corp'));
    insert accounts;

    Test.startTest();
    try {
      List<RecordDataModels.RecordWrapper> acctsWrapper = DynamicDataTableCtrl.getRecordWrappers(
        'Account',
        'Id, Nameeeee, AccountNumber, Owner.Name',
        'Name != null',
        accounts[0].Id
      );
    } catch (Exception e) {
      Assert.isTrue(e.getMessage().contains('Script-thrown exception'));
    }
    Test.stopTest();
  }

  @isTest
  static void test_getFieldInfo() {
    Test.startTest();
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    DynamicDataTableCtrl.TableProperties tableProps1 = DynamicDataTableCtrl.getTableProperties(
      'Account',
      'Id, Name, AccountNumber, Owner.Name'
    );
    DynamicDataTableCtrl.TableProperties tableProps2 = DynamicDataTableCtrl.getTableProperties(
      'Contact',
      'Id, Name, Phone, Email, Account.Name'
    );
    Test.stopTest();

    Assert.areEqual(tableProps1.columnHeaders[1], 'Account Name');
    Assert.areEqual(tableProps1.columnHeaders[2], 'Account Number');
    Assert.areEqual(tableProps1.columnHeaders[3], 'Owner Name');
    Assert.areEqual(tableProps1.fieldTypes[1], 'STRING');
    Assert.areEqual(tableProps1.fieldTypes[2], 'STRING');
    Assert.isTrue(tableProps1.fieldUpdateables[1]);
    Assert.isTrue(tableProps1.fieldUpdateables[2]);

    Assert.areEqual(tableProps2.columnHeaders[1], 'Full Name');
    Assert.areEqual(tableProps2.columnHeaders[2], 'Business Phone');
    Assert.areEqual(tableProps2.columnHeaders[4], 'Account Name');
    Assert.areEqual(tableProps2.fieldTypes[1], 'STRING');
    Assert.areEqual(tableProps2.fieldTypes[2], 'PHONE');
    Assert.isFalse(tableProps2.fieldUpdateables[1]);
    Assert.isTrue(tableProps2.fieldUpdateables[2]);
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
    } catch (Exception e) {
      Assert.isTrue(e.getMessage().contains('Script-thrown exception'));
    }
  }
}
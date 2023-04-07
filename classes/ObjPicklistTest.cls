/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: provides code coverage for the following classes: ObjPicklist
 * Created    : 03.21.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
@isTest
private class ObjPicklistTest {
  @isTest
  static void test_getValues() {
    ObjPicklist arlObjPickList = new ObjPicklist();
    arlObjPickList.getDefaultValue();
    arlObjPickList.getValues();
    Assert.isNotNull(arlObjPickList.getValues());
  }
}
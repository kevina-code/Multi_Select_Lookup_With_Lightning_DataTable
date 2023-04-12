/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: shared utils for LWC's
 * Created    : 04.11.2023
 */

const linkIdDelimiter = "_^_";
const linkLabelDelimiter = "^_^";
const chDelimiter = "@_@";

/**
 * helper method for multiSelectLookup.js and dynamicDataTable.js
 * @param {} items
 * @returns wrapper - a data structure containing records and other information
 */
const getDataTableWrapper = (items) => {
  const wrapper = {};
  const tempRecList = [];
  const colHeaderMap = {};
  const linkifiedColumns = [];
  // add custom properties here since we can't do that to SObject records in apex
  items.forEach((item) => {
    const tempRec = Object.assign({}, item.record);
    for (const prop in item.fieldPropertyMap) {
      if (Object.prototype.hasOwnProperty.call(item.fieldPropertyMap, prop)) {
        const fieldProperty = item.fieldPropertyMap[prop];
        tempRec[fieldProperty.columnHeader + chDelimiter] =
          fieldProperty.fieldValue;
        colHeaderMap[fieldProperty.columnHeader] = fieldProperty;
        if (fieldProperty.linkId) {
          linkifiedColumns.push(fieldProperty.columnHeader);
          tempRec[fieldProperty.columnHeader + linkIdDelimiter] =
            "/" + fieldProperty.linkId;
          tempRec[fieldProperty.linkLabel + linkLabelDelimiter] =
            fieldProperty.fieldValue;
        }
        if (fieldProperty.fieldType === "REFERENCE") {
          const relObj = {};
          relObj.Id = tempRec.Id;
          relObj.Name = tempRec.Name;
        }
      }
    }
    tempRec.objName = item.objName;
    tempRec.RecName = "/" + tempRec.Id;
    tempRecList.push(tempRec);
  });
  wrapper.records = tempRecList;
  wrapper.colHeaderMap = colHeaderMap;
  wrapper.linkifiedColumns = linkifiedColumns;
  return wrapper;
};

export { getDataTableWrapper };
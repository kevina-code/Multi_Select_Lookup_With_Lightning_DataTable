/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: dynamic data table component driven by LWC target configs and/or parent LWC's
 * Created    : 03.22.2023
 */
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { getDataTableWrapper } from "c/lwcUtils";
import getRecordWrappers from "@salesforce/apex/DynamicDataTableCtrl.getRecordWrappers";
import getTableProperties from "@salesforce/apex/DynamicDataTableCtrl.getTableProperties";

const linkIdDelimiter = "_^_";
const linkLabelDelimiter = "^_^";
const chDelimiter = "@_@";

export default class DynamicDataTable extends NavigationMixin(
  LightningElement
) {
  @api recordId;

  // target configs:
  @api title;
  @api objApiName;
  @api fieldPaths;
  @api whereClause;
  @api hideCheckboxColumn;
  @api actionsStr;
  @api suppressBottomBar;
  @api enforceAccessibleFls; // whether to enforce accessible field level security (to control visibility of columns)

  @api recordData = [];
  @api colHeaderMap = {}; // column header to column properties
  @api linkifiedColumns = [];
  @api selectedRowIds = [];
  columnHeaders = [];

  wiredRecordWrappersResult;
  draftValues = [];

  rowErrorMessages = [];
  rowErrorFieldNames = [];
  errors;
  errorCount = 0;

  fieldTypeMap = new Map([
    ["STRING", "text"],
    ["BOOLEAN", "boolean"],
    ["CURRENCY", "currency"],
    ["COMBOBOX", "text"],
    ["DATACATEGORYGROUPREFERENCE", "text"],
    ["ID", "text"],
    ["DATE", "date"],
    ["DATETIME", "date"],
    ["INTEGER", "number"],
    ["LONG", "number"],
    ["DECIMAL", "number"],
    ["DOUBLE", "number"],
    ["EMAIL", "email"],
    ["PERCENT", "percent"],
    ["PHONE", "phone"],
    ["PICKLIST", "text"],
    ["MULTIPICKLIST", "text"],
    ["TEXTAREA", "text"],
    ["TIME", "text"],
    ["URL", "url"],
    ["REFERENCE", "text"]
  ]);

  /**
   * get records to populate lightning data table with
   */
  @wire(getRecordWrappers, {
    objApiName: "$objApiName",
    fieldPaths: "$fieldPaths",
    whereClause: "$whereClause",
    recordId: "$recordId"
  })
  wiredRecordWrappers(result) {
    this.wiredRecordWrappersResult = result;
    if (result.data) {
      const wrapper = getDataTableWrapper(result.data);
      this.recordData = wrapper.records;
      this.colHeaderMap = wrapper.colHeaderMap;
      this.linkifiedColumns = wrapper.linkifiedColumns;
    } else if (result.error) {
      console.log(
        "dynamicDataTable wiredRecords error",
        result.error.body.message
      );
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error retrieving record data",
          message: result.error.body.message,
          variant: "error"
        })
      );
    }
  }

  /**
   * get field properties to apply to lightning data table
   */
  @wire(getTableProperties, {
    objApiName: "$objApiName",
    fieldPaths: "$fieldPaths"
  })
  wiredFieldProperties(result) {
    if (result.data) {
      this.columnHeaders = result.data.columnHeaders;
    } else if (result.error) {
      console.log(
        "dynamicDataTable wiredFieldProperties error",
        result.error.body.message
      );
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error retrieving field properties",
          message: result.error.body.message,
          variant: "error"
        })
      );
    }
  }

  /**
   * get record actions
   */
  get actions() {
    const actionsList = [];
    if (
      this.actionsStr !== null &&
      this.actionsStr !== undefined &&
      this.actionsStr !== ""
    ) {
      const actionArray = this.actionsStr.replace(/\s/g, "").split(",");
      actionArray.forEach((action) => {
        if (action.toUpperCase() === "VIEW") {
          actionsList.push({ label: "View", name: "view" });
        } else if (action.toUpperCase() === "EDIT") {
          actionsList.push({ label: "Edit", name: "edit" });
        } else if (action.toUpperCase() === "DELETE") {
          actionsList.push({ label: "Delete", name: "delete" });
        }
      });
    }
    return actionsList;
  }

  /**
   * assemble data table columns based on configs
   */
  get columns() {
    try {
      const fieldPathArray = this.fieldPaths.replace(/\s/g, "").split(",");
      const columnList = [];
      for (let i = 0; i < fieldPathArray.length; i++) {
        const fieldPath = fieldPathArray[i];
        const fieldProperty = this.colHeaderMap[this.columnHeaders[i]];
        const fieldType = fieldProperty.fieldType;
        const isAccessible = fieldProperty.isAccessible;
        const type = this.fieldTypeMap.get(fieldType);
        // don't create a column for the record's Id field,
        //  since it will be merged into the Name field to create a link to the record
        console.log("enforceAccessibleFls: ", this.enforceAccessibleFls);
        console.log("isAccessible: ", this.isAccessible);
        if (
          fieldPath.toUpperCase() !== "ID" &&
          (!this.enforceAccessibleFls || isAccessible)
        ) {
          const isExtendedPath = fieldProperty.isExtendedPath;
          const column = {};
          column.label = this.columnHeaders[i];
          column.type = type;
          column.editable = fieldProperty.isUpdateable;
          column.sortable = true;

          const _fieldApiName = fieldProperty.fieldApiName;
          if (fieldPath.toUpperCase() === "NAME") {
            column.fieldName = "RecName";
            column.type = "url";
            column.typeAttributes = {
              label: { fieldName: "Name" },
              target: "_blank"
            };
          } else {
            if (fieldType === "PICKLIST" && !isExtendedPath) {
              const picklistLabels = fieldProperty.picklistLabels;
              const picklistValues = fieldProperty.picklistValues;

              const optionsList = [];
              for (let _i = 0; _i < picklistLabels.length; _i++) {
                optionsList.push({
                  label: picklistLabels[_i],
                  value: picklistValues[_i]
                });
              }

              column.fieldName = _fieldApiName;
              column.type = "picklist";
              column.typeAttributes = {
                placeholder: "Select an option",
                options: optionsList, // list of all picklist options
                value: { fieldName: _fieldApiName }, // default value for picklist
                context: { fieldName: "Id" }, // binding account Id with context variable to be returned back
                fieldApiName: _fieldApiName
              };
            } else if (fieldType === "REFERENCE" && !isExtendedPath) {
              // lookup fields, base object level
              const relObjName = fieldProperty.relObjName;
              const relObjApiName = fieldProperty.relObjApiName;
              const iconName = _fieldApiName.includes("__c")
                ? "standard:record"
                : "standard:" + relObjName.toLowerCase();

              column.label = relObjName;
              column.fieldName = _fieldApiName;
              column.type = "lookup";
              column.typeAttributes = {
                placeholder: "Select " + relObjName,
                uniqueId: { fieldName: "Id" }, //pass Id of current record to lookup for context
                object: relObjApiName,
                icon: iconName,
                label: relObjName,
                displayFields: "Name",
                displayFormat: "Name",
                filters: "",
                valueId: { fieldName: _fieldApiName },
                fieldApiName: _fieldApiName,
                relObjApiName: relObjApiName,
                recordData: this.recordData
              };
            } else {
              // all other fields
              column.fieldName = this.columnHeaders[i] + chDelimiter;
              if (this.linkifiedColumns.includes(this.columnHeaders[i])) {
                column.fieldName = this.columnHeaders[i] + linkIdDelimiter;
                column.type = "url";
                column.typeAttributes = {
                  label: {
                    fieldName: this.columnHeaders[i] + linkLabelDelimiter
                  },
                  target: "_blank"
                };
              }
            }
          }
          columnList.push(column);
        }
      }

      if (this.actions.length) {
        columnList.push({
          type: "action",
          typeAttributes: {
            rowActions: this.actions,
            menuAlignment: "right"
          }
        });
      }
      return columnList;
    } catch (error) {
      console.log("-------dynamicDataTable columns error-------" + error);
    }
  }

  // handle when user selects row from data table
  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    const rowsToggledEvent = new CustomEvent("rowstoggled", {
      detail: { selectedRows }
    });
    this.dispatchEvent(rowsToggledEvent);
  }

  // handle when user performs action (view, edit, delete) on data table row
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "view":
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: row.Id,
            actionName: "view"
          }
        });
        break;
      case "edit":
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: row.Id,
            objectApiName: row.objName,
            actionName: "edit"
          }
        });
        break;
      case "delete":
        deleteRecord(row.Id)
          .then(() => {
            this.recordData = this.recordData.filter(function (record) {
              return record.Id !== row.Id;
            });
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Record Deleted",
                message: "Record deleted successfully",
                variant: "success"
              })
            );
          })
          .catch((error) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error retrieving record data",
                message: "Unable to delete record due to " + error.body.message,
                variant: "error"
              })
            );
          });
        break;
      default:
    }
  }

  // handle when user changes a cell value
  handleCellChange(event) {
    const updatedItem = event.detail.draftValues[0];
    const colHeaderName = Object.keys(updatedItem)[0];
    const recordId = Object.values(updatedItem)[1];
    const cleanColHeaderName = colHeaderName.replace(chDelimiter, "");

    const phoneMatch = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
    const fieldType = this.colHeaderMap[cleanColHeaderName].fieldType;

    let valueIsValid = true;
    if (fieldType === "PHONE") {
      valueIsValid = phoneMatch.test(
        updatedItem[cleanColHeaderName + chDelimiter]
      );
    } // add additional validations here

    const rowsError = {};
    const errorMessage = "Enter a valid " + cleanColHeaderName;
    const index = this.rowErrorMessages.findIndex((x) => x === errorMessage);
    if (!valueIsValid) {
      this.errorCount += 1;
      if (index === -1) {
        this.rowErrorMessages.push(errorMessage);
        this.rowErrorFieldNames.push(cleanColHeaderName);
      }

      rowsError[this.draftValues[0].Id] = {
        messages: this.rowErrorMessages,
        fieldNames: this.rowErrorFieldNames,
        title: "We found " + this.errorCount + " error(s)"
      };
      this.draftValues[0] = this.draftValues.find(
        (record) => record.Id === updatedItem.Id
      );
    } else {
      this.appendDraftValues(updatedItem);
      this.updateDraftValues(updatedItem);
      this.updateDataValues(updatedItem);
      if (index > -1) {
        this.rowErrorMessages.splice(index, 1);
        this.rowErrorFieldNames.splice(index, 1);
        this.errorCount -= 1;
      }
      if (this.rowErrorFieldNames.length === 0) {
        this.errorCount = 0;
      }
    }

    if (this.errorCount > 0) {
      this.errors = { rows: rowsError };
    } else {
      this.errors = {};
    }

    const saveDraftValues = updatedItem;
    const cellChangedEvent = new CustomEvent("cellchanged", {
      detail: { saveDraftValues }
    });
    this.dispatchEvent(cellChangedEvent);
  }

  // handle when user changes a picklist field value in the data table
  handlePicklistChanged(event) {
    event.stopPropagation();
    const dataReceived = event.detail.data;
    const fieldApiName = dataReceived.fieldApiName;
    const updatedItem = {
      Id: dataReceived.context
    };
    updatedItem[fieldApiName] = dataReceived.value;
    this.appendDraftValues(updatedItem);
    this.updateDraftValues(updatedItem);
    this.updateDataValues(updatedItem);
  }

  // handle when user changes a lookup field value in the data table
  handleLookupSelection(event) {
    event.stopPropagation();
    const dataReceived = event.detail.data;
    const relField = dataReceived.fieldApiName;
    const updatedItem = {
      Id: dataReceived.key
    };
    updatedItem[relField] = dataReceived.selectedId;
    this.appendDraftValues(updatedItem);
    this.updateDraftValues(updatedItem);
    this.updateDataValues(updatedItem);
  }

  // handle when user changes a cell in the table to a valid value
  appendDraftValues(item) {
    // if we have not yet added this row to the draftValues list,
    //  add it. Otherwise, find the applicable row and morph it to append the new draft value
    const colHeaderName = Object.keys(item)[0];
    if (!this.draftValues.find((record) => record.Id === item.Id)) {
      this.draftValues.push(item);
    } else {
      const filteredRow = this.draftValues.filter(function (row) {
        return row.Id === item.Id;
      })[0];
      filteredRow[colHeaderName] = item[colHeaderName];

      const index = this.draftValues.findIndex((record) => {
        return record.Id === item.Id;
      });
      this.draftValues[index] = filteredRow;
    }
  }

  // update draft values when user changes a data table cell's value
  updateDraftValues(updatedItem) {
    let draftValueChanged = false;
    const copyDraftValues = [...this.draftValues];

    const applicableRow = copyDraftValues.filter(function (row) {
      return row.Id === updatedItem.Id;
    })[0];

    for (const field in updatedItem) {
      applicableRow[field] = updatedItem[field];
      draftValueChanged = true;
    }
    const index = copyDraftValues.findIndex((row) => {
      return row.Id === updatedItem.Id;
    });
    Object.assign(copyDraftValues[index], applicableRow);
    if (draftValueChanged) {
      this.draftValues = [...copyDraftValues];
    } else {
      this.draftValues = [...copyDraftValues, updatedItem];
    }
  }

  // update recordData variable when user changes a data table cell's value
  updateDataValues(updatedItem) {
    const copyData = JSON.parse(JSON.stringify([...this.recordData]));

    // get the full record for updatedItem from this.recordData
    const applicableRecord = JSON.parse(
      JSON.stringify(
        [...this.recordData].filter(function (record) {
          return record.Id === updatedItem.Id;
        })[0]
      )
    );

    for (const field in updatedItem) {
      applicableRecord[field] = updatedItem[field];
    }
    const index = copyData.findIndex((record) => {
      return record.Id === updatedItem.Id;
    });
    Object.assign(copyData[index], applicableRecord);

    //write changes back to original data
    this.recordData = [...copyData];
  }

  // handle when user clicks the save button
  handleSave(event) {
    const colHeaderToFieldApiName = {};
    for (const prop in this.colHeaderMap) {
      colHeaderToFieldApiName[prop + chDelimiter] =
        this.colHeaderMap[prop].fieldApiName;
    }

    // replace column header names with field api names:
    const curatedDraftValues = this.draftValues.map((o) =>
      Object.fromEntries(
        Object.entries(o).map(([k, v]) => [colHeaderToFieldApiName[k] ?? k, v])
      )
    );

    const recordInputs = curatedDraftValues.slice().map((draft) => {
      const fields = Object.assign({}, draft);
      return { fields };
    });

    const promises = recordInputs.map((recordInput) =>
      updateRecord(recordInput)
    );
    Promise.all(promises)
      .then(() => {
        this.draftValues = [];
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Succeess",
            message: "Successfully updated records!",
            variant: "success"
          })
        );
        return refreshApex(this.wiredRecordWrappersResult);
      })
      .catch((error) => {
        console.log("dynamicDataTable.handleSave error", error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating records",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }
}
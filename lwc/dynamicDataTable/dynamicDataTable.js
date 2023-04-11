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
import getRecordWrappers from "@salesforce/apex/DynamicDataTableCtrl.getRecordWrappers";
import getTableProperties from "@salesforce/apex/DynamicDataTableCtrl.getTableProperties";

const linkIdDelimiter = "_^_";
const linkLabelDelimiter = "^_^";
const chDelimiter = "@_@";

export default class DynamicDataTable extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api hasLoaded = false;

  // target configs:
  @api title;
  @api objApiName;
  @api fieldPaths;
  @api whereClause;
  @api hideCheckboxColumn;
  @api actionsStr;
  @api suppressBottomBar;

  @api recordData = [];
  @api linkifiedColumns = [];
  @api selectedRowIds = [];
  @api colHeaderMap = {}; // column header to column properties
  columnHeaders = [];

  fieldTypes = [];
  fieldUpdateables = [];

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
    console.log("dynamicDataTable wiredRecords error", result.error);
    console.log("dynamicDataTable wiredRecords result.data", result.data);
    if (result.data) {
      this.hasLoaded = true;
      this.recordData = this.assimilateRecordData(result.data);
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
    console.log("dynamicDataTable wiredFieldProperties error", result.error);
    console.log(
      "dynamicDataTable wiredFieldProperties result.data",
      result.data
    );
    if (result.data) {
      this.columnHeaders = result.data.columnHeaders;
      this.fieldTypes = result.data.fieldTypes;
      this.fieldUpdateables = result.data.fieldUpdateables;
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

  // assimilate records with custom properties
  assimilateRecordData(items) {
    const tempRecList = [];
    // add custom properties here since we can't do that to SObject records in apex
    items.forEach((recordWrapper) => {
      const tempRec = Object.assign({}, recordWrapper.record);
      for (const prop in recordWrapper.fieldPropertyMap) {
        if (
          Object.prototype.hasOwnProperty.call(
            recordWrapper.fieldPropertyMap,
            prop
          )
        ) {
          const fieldProperty = recordWrapper.fieldPropertyMap[prop];
          tempRec[fieldProperty.columnHeader + chDelimiter] =
            fieldProperty.fieldValue;
          this.colHeaderMap[fieldProperty.columnHeader] = fieldProperty;
          if (fieldProperty.linkId) {
            this.linkifiedColumns.push(fieldProperty.columnHeader);
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
      tempRec.objName = recordWrapper.objName;
      tempRec.RecName = "/" + tempRec.Id;
      tempRecList.push(tempRec);
    });
    return tempRecList;
  }

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

  get columns() {
    try {
      const fieldPathArray = this.fieldPaths.replace(/\s/g, "").split(",");
      const columnList = [];
      for (let i = 0; i < fieldPathArray.length; i++) {
        const fieldPath = fieldPathArray[i];
        const fieldType = this.fieldTypes[i];
        const type = this.fieldTypeMap.get(this.fieldTypes[i]);
        const fieldProperty = this.colHeaderMap[this.columnHeaders[i]];
        if (fieldPath.toUpperCase() !== "ID") {
          const isExtendedPath = fieldProperty.isExtendedPath;
          const column = {};
          column.label = this.columnHeaders[i];
          column.type = type;
          column.editable = this.fieldUpdateables[i];
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
    } catch (error) {}
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
      // if we have not yet added this row to the draftValues list,
      //  add it. Otherwise, find the applicable row and morph it to append the new draft value
      if (!this.draftValues.find((record) => record.Id === recordId)) {
        this.draftValues.push(updatedItem);
      } else {
        const filteredRow = this.draftValues.filter(function (row) {
          return row.Id === recordId;
        })[0];
        filteredRow[colHeaderName] = updatedItem[colHeaderName];

        const index = this.draftValues.findIndex((record) => {
          return record.Id === recordId;
        });
        this.draftValues[index] = filteredRow;
      }

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

  //updates datatable
  handlePicklistChanged(event) {
    event.stopPropagation();
    let dataReceived = event.detail.data;
    const fieldApiName = dataReceived.fieldApiName;
    let updatedItem = {
      Id: dataReceived.context
    };
    updatedItem[fieldApiName] = dataReceived.value;
    this.updateDraftValues(updatedItem);
    this.updateDataValues(updatedItem);
  }

  handleLookupSelection(event) {
    event.stopPropagation();
    const dataReceived = event.detail.data;
    const relField = dataReceived.fieldApiName;
    const updatedItem = {
      Id: dataReceived.key
    };
    updatedItem[relField] = dataReceived.selectedId;
    this.updateDraftValues(updatedItem);
    this.updateDataValues(updatedItem);
  }

  updateDraftValues(updateItem) {
    let draftValueChanged = false;
    const copyDraftValues = [...this.draftValues];

    const applicableRow = copyDraftValues.filter(function (row) {
      return row.Id === updateItem.Id;
    })[0];

    for (const field in updateItem) {
      applicableRow[field] = updateItem[field];
      draftValueChanged = true;
    }
    const index = copyDraftValues.findIndex((row) => {
      return row.Id === updateItem.Id;
    });
    Object.assign(copyDraftValues[index], applicableRow);

    if (draftValueChanged) {
      this.draftValues = [...copyDraftValues];
    } else {
      this.draftValues = [...copyDraftValues, updateItem];
    }
  }

  updateDataValues(updateItem) {
    const copyData = JSON.parse(JSON.stringify([...this.recordData]));

    // get the full record for updateItem from this.recordData
    const applicableRecord = JSON.parse(
      JSON.stringify(
        [...this.recordData].filter(function (record) {
          return record.Id === updateItem.Id;
        })[0]
      )
    );

    for (const field in updateItem) {
      applicableRecord[field] = updateItem[field];
    }
    const index = copyData.findIndex((record) => {
      return record.Id === updateItem.Id;
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
    const curatedSaveDraftValues = this.draftValues.map((o) =>
      Object.fromEntries(
        Object.entries(o).map(([k, v]) => [colHeaderToFieldApiName[k] ?? k, v])
      )
    );

    const recordInputs = curatedSaveDraftValues.slice().map((draft) => {
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
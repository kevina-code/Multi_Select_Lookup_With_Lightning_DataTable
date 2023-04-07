/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: dynamic data table component driven by LWC target configs and/or parent LWC's
 * Created    : 03.22.2023
 */
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
<<<<<<< HEAD
import { updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
=======
import { deleteRecord } from "lightning/uiRecordApi";
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
import getRecordWrappers from "@salesforce/apex/DynamicDataTableCtrl.getRecordWrappers";
import getTableProperties from "@salesforce/apex/DynamicDataTableCtrl.getTableProperties";

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
<<<<<<< HEAD
=======
  @api recordLimit;
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
  @api hideCheckboxColumn;
  @api actionsStr;
  @api suppressBottomBar;

  @api recordData = [];
<<<<<<< HEAD
  @api linkifiedColumns = [];
  @api selectedRowIds = [];
  @api colHeaderToFieldApiName = {};
  @api colHeaderToFieldType = {};
  columnHeaders = [];

=======
  columnHeaders = [];
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
  fieldTypes = [];
  fieldUpdateables = [];
  @api linkifiedColumns = [];

  selectedRowIds = [];
  preselectedContactRow = ["0035w000036mj7oAAA"];

  wiredRecordWrappersResult;
  saveDraftValues = [];
  draftValues = [];

  rowErrorMessages = [];
  rowErrorFieldNames = [];
  errors;
  errorCount = 0;

  typeMap = new Map([
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
    ["REFERENCE", "id"],
    ["TEXTAREA", "text"],
    ["TIME", "text"],
    ["URL", "url"]
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
<<<<<<< HEAD
    this.wiredRecordWrappersResult = result;
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    console.log("wiredRecords error", result.error);
    console.log("wiredRecords result.data", result.data);
    if (result.data) {
      this.hasLoaded = true;
      this.recordData = this.assimilateRecordData(result.data);
    } else if (result.error) {
      console.log("wiredRecords error", result.error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error retrieving record data",
          message: result.error.body.message,
          variant: "error"
        })
      );
    }
  }

<<<<<<< HEAD
  /**
   * get field properties to apply to lightning data table
   */
  @wire(getTableProperties, {
    objApiName: "$objApiName",
    fieldPaths: "$fieldPaths"
  })
  wiredFieldProperties(result) {
    console.log("wiredFieldProperties error", result.error);
    console.log("wiredFieldProperties result.data", result.data);
    if (result.data) {
      this.columnHeaders = result.data.columnHeaders;
      this.fieldTypes = result.data.fieldTypes;
      this.fieldUpdateables = result.data.fieldUpdateables;
    } else if (result.error) {
      console.log("wiredFieldProperties error", result.error.body.message);
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
          tempRec[fieldProperty.columnHeader] = fieldProperty.fieldValue;
          this.colHeaderToFieldApiName[fieldProperty.columnHeader] =
            fieldProperty.fieldApiName;
          this.colHeaderToFieldType[fieldProperty.columnHeader] =
            fieldProperty.fieldType;
          if (fieldProperty.linkId) {
            this.linkifiedColumns.push(fieldProperty.columnHeader);
            tempRec[fieldProperty.columnHeader] = "/" + fieldProperty.linkId;
            tempRec[fieldProperty.linkLabel] = fieldProperty.fieldValue;
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
      const fieldApiNameArray = this.fieldPaths.replace(/\s/g, "").split(",");
      const columnList = [];
      for (let i = 0; i < fieldApiNameArray.length; i++) {
        const fieldApiName = fieldApiNameArray[i];
        if (fieldApiName.toUpperCase() !== "ID") {
          const column = {};
          column.label = this.columnHeaders[i];
          column.type = this.typeMap.get(this.fieldTypes[i]);
          column.editable = this.fieldUpdateables[i];
          column.sortable = true;
          if (fieldApiName.toUpperCase() === "NAME") {
            column.fieldName = "RecName";
            column.type = "url";
            column.typeAttributes = {
              label: { fieldName: "Name" },
              target: "_blank"
            };
          } else {
            column.fieldName = this.columnHeaders[i];
            if (this.linkifiedColumns.includes(this.columnHeaders[i])) {
              column.type = "url";
              column.typeAttributes = {
                label: { fieldName: this.columnHeaders[i] + "^_^" + i },
                target: "_blank"
              };
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
      console.log("columns error: ", error);
    }
  }

  // handle when user selects row from data table
  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    //this.selectedRowIds = selectedRows.map((record) => record.id);
=======
  // assimilate records with custom properties
  assimilateRecordData(items) {
    let tempRecList = [];
    items.forEach((recordWrapper) => {
      let tempRec = Object.assign({}, recordWrapper.record);
      for (const prop in recordWrapper.fieldPropertyMap) {
        if (
          Object.prototype.hasOwnProperty.call(
            recordWrapper.fieldPropertyMap,
            prop
          )
        ) {
          const fieldProperty = recordWrapper.fieldPropertyMap[prop];
          tempRec[fieldProperty.columnHeader] = fieldProperty.fieldValue;
          if (fieldProperty.linkId) {
            this.linkifiedColumns.push(fieldProperty.columnHeader);
            tempRec[fieldProperty.columnHeader] = "/" + fieldProperty.linkId;
            tempRec[fieldProperty.linkLabel] = fieldProperty.fieldValue;
          }
        }
      }
      tempRec.objName = recordWrapper.objName;
      tempRec.RecName = "/" + tempRec.Id;
      tempRecList.push(tempRec);
    });
    return tempRecList;
  }

  /**
   * get field properties to apply to lightning data table
   */
  @wire(getTableProperties, {
    objApiName: "$objApiName",
    fieldPaths: "$fieldPaths"
  })
  wiredFieldProperties(result) {
    console.log("wiredFieldProperties error", result.error);
    console.log("wiredFieldProperties result.data", result.data);
    if (result.data) {
      this.columnHeaders = result.data.columnHeaders;
      this.fieldTypes = result.data.fieldTypes;
      this.fieldUpdateables = result.data.fieldUpdateables;
    } else if (result.error) {
      console.log("wiredFieldProperties error", result.error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error retrieving field properties",
          message: result.error.body.message,
          variant: "error"
        })
      );
    }
  }

  get columns() {
    try {
      const fieldApiNameArray = this.fieldPaths.replace(/\s/g, "").split(",");

      let columnList = [];
      for (let i = 0; i < fieldApiNameArray.length; i++) {
        const fieldApiName = fieldApiNameArray[i];
        if (fieldApiName.toUpperCase() !== "ID") {
          let column = {};
          column.label = this.columnHeaders[i];
          column.type = this.typeMap.get(this.fieldTypes[i]);
          column.editable = this.fieldUpdateables[i];
          column.sortable = true;
          if (fieldApiName.toUpperCase() === "NAME") {
            column.fieldName = "RecName";
            column.type = "url";
            column.typeAttributes = {
              label: { fieldName: "Name" },
              target: "_blank"
            };
          } else {
            column.fieldName = this.columnHeaders[i];
            if (this.linkifiedColumns.includes(this.columnHeaders[i])) {
              column.label = this.columnHeaders[i];
              column.fieldName = this.columnHeaders[i];
              column.type = "url";
              column.typeAttributes = {
                label: { fieldName: this.columnHeaders[i] + "^_^" + i },
                target: "_blank"
              };
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
      console.log("columns error: ", error);
    }
  }

  // handle when user selects row from data table
  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    console.log("selectedRows: ", JSON.stringify(selectedRows));
    this.selectedRowIds = selectedRows.map((record) => record.id);
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
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
<<<<<<< HEAD
  }

  // handle when user clicks the save button
  handleSave(event) {
    this.saveDraftValues = event.detail.draftValues;
    const colHeaderToFieldApiName = this.colHeaderToFieldApiName;
    const curatedSaveDraftValues = this.saveDraftValues.map((o) =>
      Object.fromEntries(
        Object.entries(o).map(([k, v]) => [colHeaderToFieldApiName[k] ?? k, v])
      )
    );
    this.draftValues = [];

    const recordInputs = curatedSaveDraftValues.slice().map((draft) => {
      const fields = Object.assign({}, draft);
      return { fields };
    });

    const promises = recordInputs.map((recordInput) =>
      updateRecord(recordInput)
    );
    Promise.all(promises)
      .then(() => {
        this.saveDraftValues = [];
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
        console.log("error", JSON.stringify(error));
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating records",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  // handle when user changes a cell value
  handleCellChange(event) {
    this.saveDraftValues = event.detail.draftValues;
    this.draftValues = this.saveDraftValues;

    const phoneMatch = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;

    const cellChanged = this.saveDraftValues[0];
    const colHeaderName = Object.keys(cellChanged)[0];
    const fieldType = this.colHeaderToFieldType[colHeaderName];

    let valueIsValid = true;
    if (fieldType === "PHONE") {
      valueIsValid = phoneMatch.test(cellChanged[colHeaderName]);
    }

    const rowsError = {};
    const errorMessage = "Enter a valid " + colHeaderName;
    const index = this.rowErrorMessages.findIndex((x) => x === errorMessage);
    if (!valueIsValid) {
      this.errorCount += 1;
      if (index === -1) {
        this.rowErrorMessages.push(errorMessage);
        this.rowErrorFieldNames.push(colHeaderName);
      }

      rowsError[this.saveDraftValues[0].Id] = {
        messages: this.rowErrorMessages,
        fieldNames: this.rowErrorFieldNames,
        title: "We found " + this.errorCount + " error(s)"
      };
    } else {
      if (index > -1) {
        this.rowErrorMessages.splice(index, 1);
        this.rowErrorFieldNames.splice(index, 1);
        this.erroCount -= 1;
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

    const saveDraftValues = this.saveDraftValues;
    const cellChangedEvent = new CustomEvent("cellchanged", {
      detail: { saveDraftValues }
    });
    this.dispatchEvent(cellChangedEvent);
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
  }
}
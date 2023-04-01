/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: dynamic data table component driven by LWC target configs and/or parent LWC's
 * Created    : 03.22.2023
 */
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { deleteRecord } from "lightning/uiRecordApi";
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
  @api recordLimit;
  @api hideCheckboxColumn;
  @api actionsStr;

  @api recordData = [];
  columnHeaders = [];
  fieldTypes = [];
  fieldUpdateables = [];
  @api linkifiedColumns = [];

  selectedRowIds = [];
  preselectedContactRow = ["0035w000036mj7oAAA"];

  get actions() {
    let actionsList = [];
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
}
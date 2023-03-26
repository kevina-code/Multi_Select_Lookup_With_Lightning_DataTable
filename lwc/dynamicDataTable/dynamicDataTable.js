/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: dynamic data table component driven by LWC target configs and/or parent LWC's
 * Created    : 03.22.2023
 */
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecords from "@salesforce/apex/DynamicDataTableCtrl.getRecords";
import getFieldLabels from "@salesforce/apex/DynamicDataTableCtrl.getFieldLabels";
import getFieldTypes from "@salesforce/apex/DynamicDataTableCtrl.getFieldTypes";
import getFieldUpdateables from "@salesforce/apex/DynamicDataTableCtrl.getFieldUpdateables";

export default class DynamicDataTable extends NavigationMixin(
  LightningElement
) {
  @api recordId;

  // target configs:
  @api title;
  @api objApiName;
  @api fieldApiNames;
  @api whereClause;
  @api actionsStr;

  @api recordData = [];
  fieldLabels = [];
  fieldTypes = [];
  fieldUpdateables = [];

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
  @wire(getRecords, {
    objApiName: "$objApiName",
    fieldApiNames: "$fieldApiNames",
    whereClause: "$whereClause",
    recordId: "$recordId"
  })
  wiredRecords(result) {
    console.log("wiredRecords error", result.error);
    console.log("wiredRecords result.data", result.data);
    if (result.data) {
      let tempRecList = [];
      result.data.forEach((record) => {
        let tempRec = Object.assign({}, record);
        tempRec.RecName = "/" + tempRec.Id;
        tempRecList.push(tempRec);
      });
      this.recordData = tempRecList;
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

  /**
   * get field labels to populate lightning data table columns with
   */
  @wire(getFieldLabels, {
    objApiName: "$objApiName",
    fieldApiNames: "$fieldApiNames"
  })
  wiredFieldLables(result) {
    console.log("wiredFieldLables error", result.error);
    console.log("wiredFieldLables result.data", result.data);
    if (result.data) {
      this.fieldLabels = result.data;
    } else if (result.error) {
      console.log("wiredFieldLables error", result.error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error retrieving field labels",
          message: result.error.body.message,
          variant: "error"
        })
      );
    }
  }

  /**
   * get field types to format lightning data table cell values with
   */
  @wire(getFieldTypes, {
    objApiName: "$objApiName",
    fieldApiNames: "$fieldApiNames"
  })
  wiredFieldTypes(result) {
    console.log("wiredFieldTypes error", result.error);
    console.log("wiredFieldTypes result.data", result.data);
    if (result.data) {
      this.fieldTypes = result.data;
    } else if (result.error) {
      console.log("wiredFieldTypes error", result.error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error retrieving field labels",
          message: result.error.body.message,
          variant: "error"
        })
      );
    }
  }

  /**
   * get whether field is updateable to conditionally enable edit access on table cell
   */
  @wire(getFieldUpdateables, {
    objApiName: "$objApiName",
    fieldApiNames: "$fieldApiNames"
  })
  wiredFieldUpdateables(result) {
    console.log("wiredFieldUpdateables error", result.error);
    console.log("wiredFieldUpdateables result.data", result.data);
    if (result.data) {
      this.fieldUpdateables = result.data;
    } else if (result.error) {
      console.log("wiredFieldUpdateables error", result.error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error retrieving field updateables",
          message: result.error.body.message,
          variant: "error"
        })
      );
    }
  }

  get columns() {
    const fieldApiNameArray = this.fieldApiNames.replace(/\s/g, "").split(",");
    let columnList = [];
    for (let i = 0; i < fieldApiNameArray.length; i++) {
      const fieldApiName = fieldApiNameArray[i];
      if (fieldApiName.toUpperCase() !== "ID") {
        let obj = {};
        obj["label"] = this.fieldLabels[i];
        obj["type"] = this.typeMap.get(this.fieldTypes[i]);
        obj["editable"] = this.fieldUpdateables[i] === "true";
        obj["sortable"] = true;
        if (fieldApiName.toUpperCase() !== "NAME") {
          obj["fieldName"] = fieldApiName;
        } else {
          obj["fieldName"] = "RecName";
          obj["type"] = "url";
          obj["typeAttributes"] = {
            label: { fieldName: "Name" },
            target: "_blank"
          };
        }
        columnList.push(obj);
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
  }
}

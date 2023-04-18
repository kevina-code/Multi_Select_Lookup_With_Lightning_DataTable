/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: created to enable custom types to be injected into dynamicDataTable LWC
 * Created    : 04.07.2023
 */
import LightningDatatable from "lightning/datatable";
import { loadStyle } from "lightning/platformResourceLoader";
import CustomDataTableResource from "@salesforce/resourceUrl/CustomDataTable";
import DatatablePicklistTemplate from "./picklist-template.html";
import DatatableMultiPicklistTemplate from "./multi-picklist-template.html";
import LookupTemplate from "./lookup-template.html";

export default class DynamicDataTableExt extends LightningDatatable {
  static customTypes = {
    picklist: {
      template: DatatablePicklistTemplate,
      typeAttributes: [
        "label",
        "placeholder",
        "options",
        "value",
        "uniqueId",
        "fieldApiName",
        "makeColumnsReadOnly"
      ]
    },
    multipicklist: {
      template: DatatableMultiPicklistTemplate,
      typeAttributes: [
        "label",
        "placeholder",
        "options",
        "value",
        "uniqueId",
        "fieldApiName",
        "recordData",
        "makeColumnsReadOnly"
      ]
    },
    lookup: {
      template: LookupTemplate,
      typeAttributes: [
        "uniqueId",
        "object",
        "icon",
        "label",
        "displayFields",
        "displayFormat",
        "placeholder",
        "filters",
        "recordData",
        "fieldApiName",
        "makeColumnsReadOnly"
      ]
    }
  };

  constructor() {
    super();
    Promise.all([loadStyle(this, CustomDataTableResource)]).then(() => {});
  }
}
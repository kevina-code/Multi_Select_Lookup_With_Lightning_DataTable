/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: object-agnostic multi select lookup with dynamic lightning-datatable population based on selected records
 * Created    : 03.22.2023
 */
import { LightningElement, api } from "lwc";

export default class MultiSelectLookupWithDataTable extends LightningElement {
  @api recordId;

  // target configs:
  @api title;
  @api iconName;
  @api objApiName;
  @api fieldApiNames;
  @api whereClause;
  @api actionsStr;

  selectedRecords = [];
  selectedRecordsLength;
  recordData = [];

  handleSelectedRecords(event) {
    this.selectedRecords = [...event.detail.selRecords];

    let tempRecList = [];
    this.selectedRecords.forEach((record) => {
      let tempRec = Object.assign({}, record);
      tempRec.RecName = "/" + tempRec.Id;
      tempRecList.push(tempRec);
    });
    this.recordData = tempRecList;

    this.selectedRecordsLength = this.selectedRecords.length;
  }
}

/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: object-agnostic multi select lookup with dynamic lightning-datatable population based on selected records
 * Created    : 03.22.2023
 */
import { LightningElement, api } from "lwc";

export default class MultiSelectLookupWithDataTable extends LightningElement {
  @api recordId;
  @api hasLoaded;

  // target configs:
  @api title;
  @api iconName;
  @api objApiName;
  @api fieldPaths;
  @api fieldPathsForSearch;
  @api whereClause;
  @api actionsStr;

  searchResultRecordsLength;
  recordData = [];
  linkifiedColumns = [];

  handleSelectedRecords(event) {
    this.hasLoaded = false;
    const selectedRecords = [...event.detail.selectedRecs];
    this.recordData = selectedRecords;
    this.linkifiedColumns = [...event.detail.linkifiedColumns];
    this.searchResultRecordsLength = selectedRecords.length;
    this.hasLoaded = true;
  }
}
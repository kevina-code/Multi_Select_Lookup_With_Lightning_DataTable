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
  @api suppressBottomBar;

<<<<<<< HEAD
  recordData = [];
  linkifiedColumns = [];
  saveDraftValues = [];

  handleSelectedRecords(event) {
    this.recordData = [...event.detail.selectedRecs];
    this.linkifiedColumns = [...event.detail.linkifiedColumns];
  }

  handleCellChanged(event) {
    this.saveDraftValues = [...event.detail.saveDraftValues];
=======
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
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
  }
}
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
  @api fieldPaths;
  @api fieldPathsForSearch;
  @api whereClause;
  @api actionsStr;
  @api suppressBottomBar;
  @api enforceAccessibleFls; // whether to enforce accessible field level security (to control visibility of columns)
  @api makeColumnsReadOnly; // whether to make every column in the datatable read only, regardless of updateable FLS

  recordData = [];
  colHeaderMap = {};
  columnHeaders = [];
  linkifiedColumns = [];
  saveDraftValues = [];

  handleSelectedRecords(event) {
    this.recordData = [...event.detail.selectedRecs];
    this.linkifiedColumns = [...event.detail.linkifiedColumns];
    this.colHeaderMap = { ...event.detail.colHeaderMap };
    this.columnHeaders = Object.keys(this.colHeaderMap);
  }

  handleCellChanged(event) {
    this.saveDraftValues = [...event.detail.saveDraftValues];
  }
}
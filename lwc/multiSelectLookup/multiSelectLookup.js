/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: object-agnostic multi select lookup
 * Created    : 03.22.2023
 */

/* eslint-disable @lwc/lwc/no-leading-uppercase-api-name */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import retrieveSearchData from "@salesforce/apex/MultiSelectLookupCtrl.retrieveSearchData";

export default class MultiSelectLookup extends LightningElement {
  @api recordId;
  @api Label;
  @api context = "multi select lookup";
  recordLimit = "10";

  // target configs:
  @api iconName;
  @api objApiName;
  @api fieldPaths;
  @api fieldPathsForSearch;
  @api whereClause;

  searchResultWrappers = [];
  searchResultRecords = [];
  selectedRecordWrappers = [];
  selectedRecords = [];
  linkifiedColumns = [];
<<<<<<< HEAD
  colHeaderToFieldApiName = {};
  colHeaderToFieldType = {};
  selectedRows = [];
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a

  doneTypingInterval = 300;
  typingTimer;
  inputDisabled = false;
  messageFlag = false;
  isSearchLoading = false;

  @api placeholder = "Lookup record(s)...";
  searchKey;

  // retrieve records based on user search
  searchField(searchKey) {
<<<<<<< HEAD
    const selectedRecordIds = this.selectedRecords.map((record) => record.Id);
=======
    let selectedRecordIds = this.selectedRecordWrappers.map(
      (obj) => obj.record.Id
    );
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
    retrieveSearchData({
      objApiName: this.objApiName,
      fieldPaths: this.fieldPaths,
      fieldPathsForSearch: this.fieldPathsForSearch,
      value: searchKey,
      selectedRecordIds: selectedRecordIds,
      whereClause: this.whereClause,
      recordId: this.recordId
    })
      .then((result) => {
        this.searchResultWrappers = result;
        if (searchKey && searchKey.length > 0) {
          this.searchResultRecords = this.assimilateRecordData(
            this.searchResultWrappers
          );
        } else {
          this.searchResultWrappers = [];
          this.searchResultRecords = [];
          this.isSearchLoading = false;
        }

        const searchResultRecords = this.searchResultRecords;
        const linkifiedColumns = this.linkifiedColumns;
<<<<<<< HEAD
        const colHeaderToFieldApiName = this.colHeaderToFieldApiName;
        const colHeaderToFieldType = this.colHeaderToFieldType;
        const searchedEvent = new CustomEvent("searched", {
          detail: {
            searchResultRecords,
            linkifiedColumns,
            colHeaderToFieldApiName,
            colHeaderToFieldType
          }
=======
        const searchedEvent = new CustomEvent("searched", {
          detail: { searchResultRecords, linkifiedColumns }
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
        });
        this.dispatchEvent(searchedEvent);

        this.isSearchLoading = false;
        if (this.context === "multi select lookup") {
          const lookupInputContainer = this.template.querySelector(
            ".lookupInputContainer"
          );
          const clsList = lookupInputContainer.classList;
          clsList.add("slds-is-open");
        }

        if (searchKey && searchKey.length > 0 && result.length === 0) {
          this.messageFlag = true;
        } else {
          this.messageFlag = false;
        }
      })
      .catch((error) => {
        console.log("-------multiSelectLookup error-------" + error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error retrieving search data",
            message: error.body.message,
            variant: "error",
            mode: "sticky"
          })
        );
      });
  }

  // assimilate records with custom properties
<<<<<<< HEAD
  assimilateRecordData(items) {
    const tempRecList = [];
    // add custom properties here since we can't do that to SObject records in apex
    items.forEach((recordWrapper) => {
      const tempRec = Object.assign({}, recordWrapper.record);
=======
  // assimilate records with custom properties
  assimilateRecordData(items) {
    let tempRecList = [];
    items.forEach((recordWrapper) => {
      let tempRec = Object.assign({}, recordWrapper.record);
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
      for (const prop in recordWrapper.fieldPropertyMap) {
        if (
          Object.prototype.hasOwnProperty.call(
            recordWrapper.fieldPropertyMap,
            prop
          )
        ) {
          const fieldProperty = recordWrapper.fieldPropertyMap[prop];
          tempRec[fieldProperty.columnHeader] = fieldProperty.fieldValue;
<<<<<<< HEAD
          this.colHeaderToFieldApiName[fieldProperty.columnHeader] =
            fieldProperty.fieldApiName;
          this.colHeaderToFieldType[fieldProperty.columnHeader] =
            fieldProperty.fieldType;
=======
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
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

  // handle when user types keys into search field
  handleKeyChange(event) {
    // ignore unneeded keys like shift, ctrl, alt, etc
    if ((event.keyCode <= 90 && event.keyCode >= 48) || event.keyCode === 8) {
      this.isSearchLoading = true;
      const searchKey = event.target.value;
      clearTimeout(this.typingTimer);
      this.typingTimer = setTimeout(() => {
        this.searchField(searchKey);
        this.isSearchLoading = false;
        this.inputDisabled = false;
      }, this.doneTypingInterval);
    }
  }

  // method to toggle lookup result section on UI
  toggleResult(event) {
    try {
      if (this.context === "multi select lookup") {
        if (!event.target.value) {
          this.messageFlag = false;
        }
        const lookupInputContainer = this.template.querySelector(
          ".lookupInputContainer"
        );
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute("data-source");

        switch (whichEvent) {
          case "searchInputField":
            clsList.add("slds-is-open");
            this.searchField();
            break;
          case "lookupContainer":
            clsList.remove("slds-is-open");
            break;
        }
      }
    } catch (error) {
      console.log("MultiSelectLookup.toggleResult error: ", error);
    }
  }

  // set selected record when user chooses one from the search results
  setSelectedRecord(event) {
    if (this.context === "multi select lookup") {
      this.messageFlag = false;
      const recId = event.target.dataset.id;

      this.template
        .querySelector(".lookupInputContainer")
        .classList.remove("slds-is-open");
<<<<<<< HEAD
=======
      let selectedRecs = this.selectedRecordWrappers;
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a

      this.template.querySelectorAll("lightning-input").forEach((each) => {
        each.value = "";
      });

      const applicableRecord = this.searchResultRecords.find(
        (data) => data.Id === recId
      );
      this.selectedRecords.push(applicableRecord);
<<<<<<< HEAD
      const selectedRecs = this.selectedRecords;

=======

      selectedRecs = this.selectedRecords;
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
      const linkifiedColumns = this.linkifiedColumns;
      const selectedEvent = new CustomEvent("selected", {
        detail: { selectedRecs, linkifiedColumns }
      });
      this.dispatchEvent(selectedEvent);

      const userinput = this.template.querySelector('[data-id="userinput"]');
      userinput.focus();
      userinput.click();
    }
  }

  // remove record from selection when user chooses to do so
  removeRecord(event) {
    try {
      if (this.context === "multi select lookup") {
        // filter out the item that was removed by user
<<<<<<< HEAD
        const filteredRecords = this.selectedRecords.filter(function (record) {
          return record.Id !== event.detail.name;
        });

        this.selectedRecords = [...filteredRecords];
        const selectedRecs = this.selectedRecords;
=======
        const filteredRecords = this.selectedRecords.filter(function (obj) {
          return obj.Id !== event.detail.name;
        });

        this.selectedRecords = [...filteredRecords];
        let selectedRecs = this.selectedRecords;
>>>>>>> 04bc7c049c1d7e51a1c16ebc0d8b359f68cc323a
        const selectedEvent = new CustomEvent("selected", {
          detail: { selectedRecs }
        });
        this.dispatchEvent(selectedEvent);
      }
    } catch (error) {
      console.log("MultiSelectLookup.removeRecord error: ", error);
    }
  }
}
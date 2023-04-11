/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: object-agnostic multi select lookup
 * Created    : 03.22.2023
 */

/* eslint-disable @lwc/lwc/no-leading-uppercase-api-name */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import retrieveSearchData from "@salesforce/apex/MultiSelectLookupCtrl.retrieveSearchData";

const linkIdDelimiter = "_^_";
const linkLabelDelimiter = "^_^";
const chDelimiter = "@_@";

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
  selectedRecords = [];
  linkifiedColumns = [];
  colHeaderMap = {};
  selectedRows = [];

  doneTypingInterval = 300;
  typingTimer;
  inputDisabled = false;
  messageFlag = false;
  isSearchLoading = false;

  @api placeholder = "Lookup record(s)...";
  searchKey;

  // retrieve records based on user search
  searchField(searchKey) {
    const selectedRecordIds = this.selectedRecords.map((record) => record.Id);
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
        const colHeaderMap = this.colHeaderMap;
        const searchedEvent = new CustomEvent("searched", {
          detail: {
            searchResultRecords,
            linkifiedColumns,
            colHeaderMap
          }
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
        console.log(
          "-------multiSelectLookup searchField error-------" + error
        );
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

  // handle when user types keys into search field
  handleKeyChange(event) {
    try {
      // ignore unneeded keys like shift, ctrl, alt, etc
      if (
        (event.keyCode <= 90 && event.keyCode >= 48) ||
        event.keyCode === 8 ||
        event.keyCode === 27
      ) {
        this.isSearchLoading = true;
        const searchKey = event.target.value;
        clearTimeout(this.typingTimer);
        this.typingTimer = setTimeout(() => {
          this.searchField(searchKey);
          this.isSearchLoading = false;
          this.inputDisabled = false;
        }, this.doneTypingInterval);
      }
    } catch (error) {
      console.log(
        "-------multiSelectLookup handleKeyChange error-------" + error
      );
      this.dispatchEvent(
        new ShowToastEvent({
          title: "handleKeyChange error",
          message: "multiSelectLookup.handleKeyChange error",
          variant: "error"
        })
      );
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
      console.log("-------multiSelectLookup toggleResult error-------" + error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Toggle result error",
          message: "Toggle result error",
          variant: "error"
        })
      );
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

      this.template.querySelectorAll("lightning-input").forEach((each) => {
        each.value = "";
      });

      const applicableRecord = this.searchResultRecords.find(
        (data) => data.Id === recId
      );
      this.selectedRecords.push(applicableRecord);
      const selectedRecs = this.selectedRecords;

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
        const filteredRecords = this.selectedRecords.filter(function (record) {
          return record.Id !== event.detail.name;
        });

        this.selectedRecords = [...filteredRecords];
        const selectedRecs = this.selectedRecords;
        const selectedEvent = new CustomEvent("selected", {
          detail: { selectedRecs }
        });
        this.dispatchEvent(selectedEvent);
      }
    } catch (error) {
      console.log("-------multiSelectLookup removeRecord error-------" + error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error removing records",
          message: "Error removing records",
          variant: "error"
        })
      );
    }
  }
}
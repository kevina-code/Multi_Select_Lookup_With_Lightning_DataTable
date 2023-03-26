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
  @api recordLimit = "10";

  // target configs:
  @api iconName;
  @api objApiName;
  @api fieldApiNames;
  @api whereClause;

  searchWrappers = [];
  searchResultRecords = [];
  selectedRecords = [];

  messageFlag = false;
  isSearchLoading = false;
  @api placeholder = "Search..";
  searchKey;

  // method to retrieve records based on user search
  searchField() {
    var selectedRecordIds = [];
    this.selectedRecords.forEach((ele) => {
      selectedRecordIds.push(ele.Id);
    });

    retrieveSearchData({
      objApiName: this.objApiName,
      fieldApiNames: this.fieldApiNames,
      value: this.searchKey,
      selectedRecordIds: selectedRecordIds,
      whereClause: this.whereClause,
      recordId: this.recordId,
      recordLimit: this.recordLimit
    })
      .then((result) => {
        this.searchWrappers = result;
        this.searchResultRecords = this.searchWrappers.map((obj) => obj.record);

        this.isSearchLoading = false;
        if (this.context === "multi select lookup") {
          const lookupInputContainer = this.template.querySelector(
            ".lookupInputContainer"
          );
          const clsList = lookupInputContainer.classList;
          clsList.add("slds-is-open");
        }

        if (this.searchKey.length > 0 && result.length == 0) {
          this.messageFlag = true;
        } else {
          this.messageFlag = false;
        }
      })
      .catch((error) => {
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

  // update searchKey property on input field change
  handleKeyChange(event) {
    // ignore the following key presses: shift, control, command, etc... but include the delete key and numbers/letters:
    if ((event.keyCode <= 90 && event.keyCode >= 48) || event.keyCode === 8) {
      this.isSearchLoading = true;
      const searchKey = event.target.value;
      if (searchKey) {
        this.searchKey = searchKey;
        setTimeout(() => {
          this.searchField();
        }, "300");
      } else {
        setTimeout(() => {
          this.searchWrappers = [];
          this.searchResultRecords = [];
          this.selectedRecords = [];
          this.isSearchLoading = false;
        }, "300");
      }

      setTimeout(() => {
        const searchResultRecords = this.searchResultRecords;
        const searchedEvent = new CustomEvent("searched", {
          detail: { searchResultRecords }
        });
        this.dispatchEvent(searchedEvent);
      }, "300");
    }
  }

  // method to toggle lookup result section on UI
  toggleResult(event) {
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
  }

  setSelectedRecord(event) {
    if (this.context === "multi select lookup") {
      this.messageFlag = false;
      var recId = event.target.dataset.id;
      let applicableRecords = this.searchResultRecords.find(
        (data) => data.Id === recId
      );
      this.selectedRecords.push(applicableRecords);
      this.template
        .querySelector(".lookupInputContainer")
        .classList.remove("slds-is-open");
      let selRecords = this.selectedRecords;
      this.template.querySelectorAll("lightning-input").forEach((each) => {
        each.value = "";
      });

      const userinput = this.template.querySelector('[data-id="userinput"]');
      userinput.focus();
      userinput.click();

      const selectedEvent = new CustomEvent("selected", {
        detail: { selRecords }
      });
      this.dispatchEvent(selectedEvent);
    }
  }

  removeRecord(event) {
    if (this.context === "multi select lookup") {
      let selectedRecordIds = [];
      for (let i = 0; i < this.selectedRecords.length; i++) {
        if (event.detail.name !== this.selectedRecords[i].Id)
          selectedRecordIds.push(this.selectedRecords[i]);
      }

      this.selectedRecords = [...selectedRecordIds];
      let selRecords = this.selectedRecords;

      const selectedEvent = new CustomEvent("selected", {
        detail: { selRecords }
      });
      this.dispatchEvent(selectedEvent);
    }
  }
}
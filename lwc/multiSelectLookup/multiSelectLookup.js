/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: object-agnostic multi select lookup with dynamic lightning-datatable population based on selected records
 * Created    : 03.22.2023
 */

/* eslint-disable @lwc/lwc/no-leading-uppercase-api-name */
import { LightningElement, api } from "lwc";
import retrieveSearchData from "@salesforce/apex/MultiSelectLookupCtrl.retrieveSearchData";

export default class MultiSelectLookup extends LightningElement {
  @api title;
  @api objApiName;
  @api fieldApiNames;
  @api Label;
  searchRecords = [];
  selectedRecords = [];
  @api iconName;
  messageFlag = false;
  isSearchLoading = false;
  @api placeholder = "Search..";
  searchKey;
  delayTimeout;

  searchField() {
    var selectedRecordIds = [];
    this.selectedRecords.forEach((ele) => {
      selectedRecordIds.push(ele.Id);
    });

    retrieveSearchData({
      objApiName: this.objApiName,
      fieldApiNames: this.fieldApiNames,
      value: this.searchKey,
      selectedRecordIds: selectedRecordIds
    })
      .then((result) => {
        this.searchRecords = result;
        this.isSearchLoading = false;
        const lookupInputContainer = this.template.querySelector(
          ".lookupInputContainer"
        );
        const clsList = lookupInputContainer.classList;
        clsList.add("slds-is-open");

        if (this.searchKey.length > 0 && result.length == 0) {
          this.messageFlag = true;
        } else {
          this.messageFlag = false;
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  // update searchKey property on input field change
  handleKeyChange(event) {
    this.isSearchLoading = true;
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this.delayTimeout = setTimeout(() => {
      this.searchKey = searchKey;
      this.searchField();
    }, 300);
  }

  // method to toggle lookup result section on UI
  toggleResult(event) {
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

  setSelectedRecord(event) {
    var recId = event.target.dataset.id;
    let newsObject = this.searchRecords.find((data) => data.Id === recId);
    this.selectedRecords.push(newsObject);
    this.template
      .querySelector(".lookupInputContainer")
      .classList.remove("slds-is-open");
    let selRecords = this.selectedRecords;
    this.template.querySelectorAll("lightning-input").forEach((each) => {
      each.value = "";
    });

    const selectedEvent = new CustomEvent("selected", {
      detail: { selRecords }
    });

    const userinput = this.template.querySelector('[data-id="userinput"]');
    userinput.focus();
    userinput.click();

    this.dispatchEvent(selectedEvent);
  }

  removeRecord(event) {
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
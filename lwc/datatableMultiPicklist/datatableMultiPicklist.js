/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: created to enable multi select picklist type to be injected into dynamicDataTable LWC
 * Created    : 04.07.2023
 */
import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class DatatableMultiPicklist extends NavigationMixin(
  LightningElement
) {
  @api label;
  @api placeholder;
  @api uniqueId;
  @api options;
  @api fieldApiName;
  @api recordData;
  @api value;
  @api makeColumnsReadOnly;

  optionsDynamic;
  optionsMaster;
  selectedValues = [];
  hasLoaded = false;

  renderedCallback() {
    if (!this.hasLoaded) {
      this.optionsDynamic = [...this.options];
      this.optionsMaster = [...this.options];
      // get the values from the applicable multi select picklist:
      let valuesStr;
      for (let i = 0; i < this.recordData.length; i++) {
        const record = this.recordData[i];
        if (record.Id === this.uniqueId) {
          const values = record[this.fieldApiName];
          if (record[this.fieldApiName]) {
            valuesStr = values;
          }
          break;
        }
      }

      if (valuesStr) {
        const valuesList = valuesStr.replace(/\s/g, "").split(";");
        const optionsDynamic = [...this.optionsDynamic];
        for (let i = 0; i < valuesList.length; i++) {
          this.selectedValues.push(valuesList[i]);
          optionsDynamic.splice(
            optionsDynamic.findIndex(
              (option) => option.label === valuesList[i]
            ),
            1
          );
        }
        this.optionsDynamic = optionsDynamic;
      }
      this.value = "";
      this.hasLoaded = true;
    }
  }

  // handle when user changes the multi select picklist dropdown:
  handleSelect(event) {
    this.value = "";
    if (!this.selectedValues.includes(event.target.value)) {
      this.selectedValues.push(event.target.value);
    }
    this.modifyOptions();
  }

  // handle when user removes a selected value:
  handleRemove(event) {
    this.value = "";
    const valueRemoved = event.target.name;
    this.selectedValues.splice(this.selectedValues.indexOf(valueRemoved), 1);
    this.modifyOptions();
  }

  // modify the options as the user interacts with the multi select picklist:
  modifyOptions() {
    this.optionsDynamic = this.optionsMaster.filter((elem) => {
      if (!this.selectedValues.includes(elem.value)) {
        return elem;
      }
    });

    //fire event to send uniqueId and selected value to the data table
    this.dispatchEvent(
      new CustomEvent("multipicklistchanged", {
        composed: true,
        bubbles: true,
        cancelable: true,
        detail: {
          data: {
            uniqueId: this.uniqueId,
            fieldApiName: this.fieldApiName,
            values: this.selectedValues
          }
        }
      })
    );
  }
}
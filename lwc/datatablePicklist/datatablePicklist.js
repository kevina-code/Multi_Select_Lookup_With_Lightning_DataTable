/**
 * Author       : Lakshay Katney (live.playg.app)
 * Description  : lookup component to be used in Lightning DataTable
 * Created      : 05.17.2021
 *
 * Revisions
 * Date : Name : Notes
 * 04.10.2023 : Kevin Antonioli (braveitnow@pm.me) : modify to be object agnostic/dynamic to work with dynamicDataTable LWC
 */
import { LightningElement, api } from "lwc";

export default class DatatablePicklist extends LightningElement {
  @api label;
  @api placeholder;
  @api options;
  @api value;
  @api uniqueId;
  @api fieldApiName;
  @api makeColumnsReadOnly;

  handleChange(event) {
    console.log("makeColumnsReadOnly: ", this.makeColumnsReadOnly);
    //show the selected value on UI
    this.value = event.detail.value;

    //fire event to send uniqueId and selected value to the data table
    this.dispatchEvent(
      new CustomEvent("picklistchanged", {
        composed: true,
        bubbles: true,
        cancelable: true,
        detail: {
          data: {
            uniqueId: this.uniqueId,
            value: this.value,
            fieldApiName: this.fieldApiName
          }
        }
      })
    );
  }
}
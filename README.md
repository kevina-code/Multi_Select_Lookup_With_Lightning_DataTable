# Multi-Select-Lookup-with-Lightning-Data-Table

Object-agnostic multi select lookup that dynamically drives a lightning data table.
* Leverages [lightning-datatable](https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/example)
* Object-agnostic - can be used with any standard or custom object
* Easily configurable - just configure the parameters with desired object name, fields, where clause, etc
* Reusable - configure multiple instances across objects without updating the code
* Ability to use dynamic id fields in optional where clause
* Ability to configure multiple search fields (not just Name) to bind to lookup search query
* Ability to display other fields (like Email and Phone for example) in the search results
* Reusable - no need to edit the code, just adjust config parameters

Deploy to Salesforce: https://live.playg.app/play/reusable-multiselect-lookup-that-20230325

```html
<c-multi-select-lookup-with-data-table
    title="Contact lookup/selection"
    icon-name="standard:contact"
    obj-api-name="Contact"
    field-paths="Id, Name, Phone, Email"
    field-paths-for-search="Name, Email"
    where-clause="AccountId = :recordId ORDER BY Name"
    actions-str="view, edit"
    record-id={recordId}
    placeholder="Lookup record..."
    onrowstoggled={rowToggleHandler} <!-- name of your method to run when user toggles the checkbox on a row -->
   >
</c-multi-select-lookup-with-data-table>
```

![image](https://user-images.githubusercontent.com/124932501/227801209-91b19675-9e83-4a60-b563-eabb4277bf76.png)

![image](https://user-images.githubusercontent.com/124932501/227801225-993e07b1-6d49-4f21-9c91-7722d2ce4e9a.png)

![image](https://user-images.githubusercontent.com/124932501/227801245-2a9187a6-fe95-4048-9266-881ce0d5d802.png)

![image](https://user-images.githubusercontent.com/124932501/227801599-e5beba62-d1d8-468e-9f2d-940aa1e6fb9e.png)

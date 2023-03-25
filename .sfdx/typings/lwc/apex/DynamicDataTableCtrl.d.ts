declare module "@salesforce/apex/DynamicDataTableCtrl.getRecords" {
  export default function getRecords(param: {objApiName: any, fieldApiNames: any, whereClause: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/DynamicDataTableCtrl.getFieldLabels" {
  export default function getFieldLabels(param: {objApiName: any, fieldApiNames: any}): Promise<any>;
}
declare module "@salesforce/apex/DynamicDataTableCtrl.getFieldTypes" {
  export default function getFieldTypes(param: {objApiName: any, fieldApiNames: any}): Promise<any>;
}
declare module "@salesforce/apex/DynamicDataTableCtrl.getFieldUpdateables" {
  export default function getFieldUpdateables(param: {objApiName: any, fieldApiNames: any}): Promise<any>;
}

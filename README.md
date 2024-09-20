# Application Integration Examples

This repo has a suite of Application Integration example demos that you can install and run in your environment. 

* [salesforce](./salesforce/) folder includes code to deploy a Salesforce App with the appropriate settings to run the Salesforce to BigQuery integration demo.
* [salesforce-to-bq](./salesforce-to-bq/) folder includes the Application Integration to accept a Salesforce opportunity and convert it to a BigQuery record.
* [custom-connector](./custom-connector/) folder includes the code to deploy a custom connector to Application Integration.
* [terraform](./terraform/) folder contains the code to deploy the `helloworld-custom-connector`


## TODOs
* Organize Terraform code into modules for each folder in this repository
* Complete Terraform code to deploy the Custom Connector (`customer-connector`) resources to Google Cloud
* Update Terraform to deploy `salesforce` and `salesforce-to-bq` Application Integration examples

# Salesforce to BQ Application Integration
This is the example [Salesforce Opportunity to BigQuery order Application Integration](https://cloud.google.com/application-integration/docs/automate-salesforce-opportunity-to-bigquery-order) listed in our public documentation.

## Prerequisites
1. [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
2. [Enable DevHub for your org](https://www.youtube.com/watch?v=cKzBSru9Qu4)
3. Update the `salesforce-to-bq/integration_user.json` `username` and `email` fields.
4. Update the following fields in `salesforce/SalesforceGoogleIntegration/force-app/main/default/connectedApps/googleappintegration.connectedApp-meta.xml` 
  * contactEmail 
  * consumerKey

## Commands to test the Salesforce project in a Scratch org.

0. Change directory into the `salesforce/SalesforceGoogleIntegration` directory.
```shell
cd salesforce/SalesforceGoogleIntegration
```

1. Enable DevHub on your Salesforce organization.
```shell
sf org login web --set-default-dev-hub --alias DevHub
```

2. Create a scratch organization with a alias of `myScratch`.
```shell
sf org create scratch --edition developer -a myScratch
```

3. Generate a password for the default user so that you can login via the UI.
```shell
sf org generate password --target-org myScratch
```

4. Display the default user for the scratch org.
```shell
sf org display user --target-org myScratch
```

5. Create the integration user.  
```shell
cd 
sf org create user --set-alias int-user --definition-file ../../salesforce-to-bq/salesforce-config/integration_user.json -o myScratch
```

When you execute the `sf org create user` command it may display an error; however, the user was created in the org.  You can login to the org to check. 
```shell
Error (1): Cannot create an AuthInfo instance that will overwrite existing auth data.
```

6. Deploy the changes to the scratch organization.
Preview the changes.
```shell
sf project deploy preview --target-org myScratch
```

This will deploy the changes.
```shell
sf project deploy start --target-org myScratch
```

You should see the the something similar to the one below on your screen.
```shell
Deploying v61.0 metadata to YOURTESTUSER@example.com using the v61.0 SOAP API.
Deploy ID: ID
Status: Succeeded | ████████████████████████████████████████ | 5/5 Components | Tracking: 5/5

Deployed Source
===================================================================================================================================================================================================
| State   Name                                Type                       Path                                                                                                                       
| ─────── ─────────────────────────────────── ────────────────────────── ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 
| Created googleappintegration                ConnectedApp               force-app/main/default/connectedApps/googleappintegration.connectedApp-meta.xml                                            
| Created googleappintegration                PermissionSet              force-app/main/default/permissionsets/googleappintegration.permissionset-meta.xml                                          
| Created ChangeEvents_AccountChangeEvent     PlatformEventChannelMember force-app/main/default/platformEventChannelMembers/ChangeEvents_AccountChangeEvent.platformEventChannelMember-meta.xml     
| Created ChangeEvents_CaseChangeEvent        PlatformEventChannelMember force-app/main/default/platformEventChannelMembers/ChangeEvents_CaseChangeEvent.platformEventChannelMember-meta.xml        
| Created ChangeEvents_OpportunityChangeEvent PlatformEventChannelMember force-app/main/default/platformEventChannelMembers/ChangeEvents_OpportunityChangeEvent.platformEventChannelMember-meta.xml 

```
## Troubleshooting
* [Generate a password for a scratch org user](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_passwd.htm)

### Permission Set Definition
[Permission Set XML Definition](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_permissionset.htm)

### List Orgs
```shell
sf org list
```


### Extract all data from Salesforce

1. [Enable DevHub](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_enable_devhub.htm) in your Salesforce organization.

2. Create a Salesforce Project in your project directory
```shell
sf project generate --name SalesforceGoogleIntegration
```

3. Create a Project manifest
```shell
cd SalesforceGoogleIntegration
sf project generate manifest --output-dir ./manifest --from-org DevHub
```

4. Retrieve all the metadata listed in the `package.xml` from the Salesforce organization.
```shell
sf project retrieve start  --target-org DevHub --manifest manifest/package.xml
```

### Push changes to a Salesforce organization
This is to preview changes before you push them.
```shell
sf project deploy preview --target-org myScratch
```

This will deploy the changes.
```shell
sf project deploy start --target-org myScratch
```


# Create a Permission Set
This command does **not** work and this is not the best way to deploy metadata into an organization.
```shell
sf deploy metadata -m PermissionSet:sfdx-int-per -d salesforce-config/integration_permission_set.xml -o myScratch
```


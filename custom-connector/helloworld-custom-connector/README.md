# Application Integration custom-connector

This folder includes all the code and documentation necessary to deploy an Application Integration custom connector.

## TODOS
* Upload my custom connector config here!
* Create script that deploys custom connector and Applicaton Integration that uses custom connector.


## How to create a Custom Connector?
You should already have a OpenAPI spec created, then upload it to Google Cloud Storage and make it publicly accessible.  Why is it publicly accessible?  This is required as part of the Custom Connector configuration and I assume they will change this to allow a service account to access it securely instead.

For this example, you will use the `helloworld-openapi.yaml` file included in this directory, but you must upload it to a new Cloud Storage bucket and make the bucket publicly accessible.  

1. Create a [custom connector](https://cloud.google.com/application-integration/docs/create-custom-connector#create-with-direct-connectivity).


## Create a Service Account for the Application Integration Connection
The Application Integration Connection will need a Service Account (SA) with permissions to invoke the Cloud Function.
Create a new SA and grant it the following role.
* `Cloud Functions Invoker`


## Create an Application Integration Connection

1. Update the `helloworld-connection.json` file to include (line 23) to the correct hostname for you Cloud Function.
```json
{ ...
    "host": "https://REPLACE_YOUR_DOMAIN.cloudfunctions.net"
}
```

2. Create the Connection, which will use the Custom Connector that you created above. 
```shell
export project=YOUR_PROJECT
export region=YOUR_REGION
export APPINT_CUSTOM_SA=YOUR_SA
integrationcli connectors create -n helloworld-cf-connection -f custom-connector/helloworld-connection.json -p $project -r $region --sa $APPINT_CUSTOM_SA --wait
```
```


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.32.0"
    }
  }
}

# # google_client_config and kubernetes provider must be explicitly specified like the following.
# data "google_client_config" "default" {
#   access_token = ""
# }



provider "google" {
  project = var.project_id
#   region  = var.compute_region
#   zone = var.compute_zone
}

# enable the required GCP services
# disabled for testing
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = var.project_id
  service = each.key
   disable_dependent_services = true
}

# ** SA for the Connector **
resource "google_service_account" "app_int_custom_connector_sa" {
  account_id   = var.custom_connector_sa_name
  display_name = "App Int Custom Connector SA" 
  description  = "Service account for the App Int Custom Connector Example." # Optional
}

# assign role to the service account
resource "google_project_iam_member" "assign_role_to_custom_connector_sa" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.app_int_custom_connector_sa.email}"
}

# ** Create the Custom Connector and the Connection **
# 1. Create the Custom Connector
resource "null_resource" "create_custom_connector" {
   
  provisioner "local-exec" {
    when = create
    command = "integrationcli connectors custom create -n ${var.custom_connector_name} --type OPEN_API --default-token"
  }

  provisioner "local-exec" {
    when = destroy
    command = "integrationcli connectors custom delete -n ${var.custom_connector_name} --default-token"
  }
}

# 2. Find and replace values in the Custom Connector Version config file first.
resource "null_resource" "find_replace_config_custom_connector_version" {
   
  provisioner "local-exec" {
    when = create
    command = "cp ../helloworld-custom-connector/helloworld-custom-connector-version.json ../helloworld-custom-connector/helloworld-custom-connector-version.backup.json  && python3 find_replace.py ${var.custom_connector_json_file} REPLACE_PROJECT:${var.project_id} REPLACE_CONNECTOR_NAME:${var.custom_connector_name} REPLACE_OPENAPI_URL:${var.custom_connector_openapi_url} REPLACE_SERVICE_ACCOUNT:${var.custom_connector_sa_name}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "mv ../helloworld-custom-connector/helloworld-custom-connector-version.backup.json ../helloworld-custom-connector/helloworld-custom-connector-version.json  && rm -f ../helloworld-custom-connector/helloworld-custom-connector-version.backup.json"
  }
  depends_on = [null_resource.create_custom_connector
                ]
}

# 3. Create the Custom Connector Version (openapi specification)
resource "null_resource" "create_custom_connector_version" {
   
  provisioner "local-exec" {
    when = create
    command = "integrationcli connectors custom versions create -n ${var.custom_connector_name} -f ../helloworld-custom-connector/helloworld-custom-connector-verson.json --id 1 --default-token"
  }

  # there is no delete command for the custom connector version
  # provisioner "local-exec" {
  #   when = destroy
  #   command = ""
  # }

  depends_on = [
                null_resource.find_replace_config_custom_connector_version
                ]
}

# 4. Create the Connection
resource "google_integration_connectors_connection" "helloworld_custom_connection" {
  name     = var.app_int_connection_name
  location = var.connector_region
  connector_version = "projects/${var.project_id}/locations/global/customConnectors/${var.custom_connector_name}/customConnectorVersions/1"
  description = "Helloworld Custom Connector Connection created by Terraform"
  service_account=google_service_account.app_int_custom_connector_sa.email
  config_variable {
      key = "project_id"
      string_value = var.project_id
  }
  node_config {
    min_node_count = 0
    max_node_count = 1
  }

  depends_on = [
    null_resource.create_custom_connector,
    null_resource.create_custom_connector_version
                ]
}

# ***
# Deploy the integration
# ***
# 1. Find and replace values in config files
resource "null_resource" "find_replace_values_in_app_integration" {

  # this does not deploy both intergrations; it only deploys one of them.
  provisioner "local-exec" {
    when = create
    interpreter = ["bash", "-c"] 
    command = "cp ../custom-connector/helloworld-custom-connector-integration/prod/helloworld-custom-connector-version.json ../helloworld-custom-connector/helloworld-custom-connector-version.backup.json  && python3 find_replace.py ${var.custom_connector_json_file} REPLACE_PROJECT:${var.project_id} REPLACE_CONNECTOR_NAME:${var.custom_connector_name} REPLACE_OPENAPI_URL:${var.custom_connector_openapi_url} REPLACE_SERVICE_ACCOUNT:${var.custom_connector_sa_name}"
  }
#     provisioner "local-exec" {
#         when = create
#         interpreter = ["bash", "-c"]
#         command = "integrationcli integrations create -f integrations/api_count/src/cl-getApiCount-tf.json -n cl-getApiCount-tf -p ${var.project_id} -r ${var.connector_region} --default-token"
#   }

  provisioner "local-exec" {
    when    = destroy
    interpreter = ["bash", "-c"] 
    command = "integrationcli integrations delete -n cl-getApiCount-tf --default-token"
  }
   depends_on = [
                ]
}


# 2. Upload integration
resource "null_resource" "upload_integration" {

  # this does not deploy both intergrations; it only deploys one of them.
  provisioner "local-exec" {
    when = create
    interpreter = ["bash", "-c"] 
    command = "integrationcli integrations apply -f integrations/api_count/ -e dev -p ${var.project_id} -r ${var.connector_region} --default-token"
  }
#     provisioner "local-exec" {
#         when = create
#         interpreter = ["bash", "-c"]
#         command = "integrationcli integrations create -f integrations/api_count/src/cl-getApiCount-tf.json -n cl-getApiCount-tf -p ${var.project_id} -r ${var.connector_region} --default-token"
#   }

  provisioner "local-exec" {
    when    = destroy
    interpreter = ["bash", "-c"] 
    command = "integrationcli integrations delete -n cl-getApiCount-tf --default-token"
  }
   depends_on = [null_resource.find_replace_values_in_app_integration
                ]
}






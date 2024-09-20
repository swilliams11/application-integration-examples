variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "integrations.googleapis.com",
    "connectors.googleapis.com",
    "cloudfunctions.googleapis.com"
  ]
}

variable "project_id" {
  type    = string
  default = "MY_PROJECT_ID"
}

variable "integration_region" {
  type    = string
  default = "us-central1"
}

variable "project_number" {
    type = string
    default = "MY_PROJECT_NUMBER"
}

variable "connector_region"{
    type = string
    default = "us-central1"
}

variable "custom_connector_sa_name"{
    type = string
    default = "app-int-custom-connector-sa-tf"
}

variable "custom_connector_name"{
    type = string
    default = "helloworld-cf-connector-tf"
}

variable "custom_connector_openapi_url"{
    type = string
    default = "https://storage.googleapis.com/BUCKET_NAME/helloworld-openapi.yaml"
}


variable "app_int_connection_name"{
    type = string
    default = "helloworld-cf-connection-tf"
}

variable "intergrations_src_folder"{
  type = string
    default = "integrations/api_count_bq/src/"
}

variable "custom_connector_json_file"{
  type = string
    default = "../helloworld-custom-connector/helloworld-custom-connector-version.json"
}
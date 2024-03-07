# Cloud Function 2
locals {
  function_source_path1 = "cf2"
}
data "archive_file" "function1_zip" {
  type        = "zip"
  source_dir  = local.function_source_path1
  output_path = "${local.function_source_path1}/function1_code.zip"
}
resource "google_storage_bucket_object" "function_code_2" {
  name   = "source.zip"
  bucket = google_storage_bucket.usecase1-123.name
  source = data.archive_file.function1_zip.output_path
}
resource "google_cloudfunctions_function" "process_csv1" {
  name                  = "process-csv1"
  runtime               = "python310"
  project               = "sbox-ujjal-ci-cd-capabilities" #  GCP project ID
  source_archive_bucket = google_storage_bucket.usecase1-123.name
  source_archive_object = google_storage_bucket_object.function_code_2.name
  entry_point           = "process_csv_file" # actual function entry point
  region                = "us-central1" 
  available_memory_mb   = 256
  timeout               = "60"
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.usecase1-123.name
  }
  environment_variables = {
    BIGQUERY_DATASET = "sbox-ujjal-ci-cd-capabilities.usecasegrads" # Replace with your BigQuery dataset
    BIGQUERY_TABLE   = "sbox-ujjal-ci-cd-capabilities.usecasegrads" # Replace with your BigQuery table
  }
}

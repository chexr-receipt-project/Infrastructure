variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "cherx-api"
}

variable "docdb_instance_class" {
  default = "db.t3.medium"
}

variable "docdb_password" {
    default = "$test12345"
}

variable "lambda_function_source_key" {
  default = "source/default_source.zip"
}

variable "mongo_db_name" {
  default = "cherx_dev"
}

variable "lambda_function_runtime" {
  default = "python3.8"
}


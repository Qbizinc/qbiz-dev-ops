variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type for dbt"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair registered in AWS for instance access"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the instance will be launched"
  type        = string
}

variable "dbt_project_git_url" {
  description = "HTTPS or SSH Git URL for your dbt project repository"
  type        = string
}

variable "dbt_target" {
  description = "The dbt target environment defined in your dbt project's profiles.yml"
  type        = string
  default     = "dev"
}

variable "dbt_snowflake_version" {
  description = "Specific version of dbt-snowflake to install (e.g., 1.6.2). Pin this!"
  type        = string
  default = "9.7.2"
}

# --- Snowflake Specific Variables ---
variable "snowflake_credentials_arn" {
  description = "ARN of the AWS Secrets Manager secret holding Snowflake 'snowflake_user' and 'snowflake_password'"
  type        = string
  sensitive   = true
}

variable "snowflake_account" {
  description = "Snowflake account identifier (e.g., xy12345.region.provider)"
  type        = string
}

variable "snowflake_role" {
  description = "Snowflake role for the dbt user"
  type        = string
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse for dbt runs"
  type        = string
}

variable "snowflake_database" {
  description = "Target Snowflake database for dbt"
  type        = string
}

variable "snowflake_schema" {
  description = "Target Snowflake schema for dbt output"
  type        = string
}
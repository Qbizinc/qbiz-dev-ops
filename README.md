# Qbiz DevOps  
Infrastructure & Service Deployment Repository  

## Prerequisites  

1. Configure your AWS CLI with a profile that has sufficient permissions to create resources in the Qbiz AWS account. Ensure the region is set to `us-west-2`.  
2. Within each Terraform module, populate the `.tfvars` file with the appropriate secrets and values for each variable to provision the infrastructure.  

## Running the Code  

Initialize Terraform, review the execution plan, and apply the configuration:  

```sh
terraform init  
terraform plan -var-file="qbiz_dbt_snowflake.tfvars"  
terraform apply -var-file="qbiz_dbt_snowflake.tfvars"  
```  

## Destroying the Infrastructure  

To tear down the deployed infrastructure, run:  

```sh
terraform destroy -var-file="qbiz_dbt_snowflake.tfvars"  

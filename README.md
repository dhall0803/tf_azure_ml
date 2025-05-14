# Azure Machine Learning Terraform Module

This Terraform module deploys the core infrastructure required for an Azure Machine Learning environment. The following Azure resources are provisioned:

## Resources Deployed

- **Resource Group**: A dedicated resource group for all resources.
- **Application Insights**: For monitoring and logging ML workloads.
- **User Assigned Managed Identity**: For use by the Machine Learning Workspace to enable access to the Key Vault to use the Customer Managed Key.
- **Key Vault**: To securely store secrets, keys, and certificates, with RBAC enabled and a key for encryption/signing.
- **Storage Account**: General-purpose v2 storage with geo-redundant storage (GRS) replication for data storage.
- **Azure Machine Learning Workspace**: The main workspace for managing ML assets and experiments.
- **Role Assignments**: RBAC assignments for administrators and service principals to access Key Vault and Storage Account as needed.

## Usage

1. Configure your `terraform.tfvars` with the required variables (such as location, admin object IDs, etc).
2. Run `terraform init` to initialize the working directory.
3. Run `terraform apply` to deploy the resources.

## Requirements
- Terraform >= 1.10.0
- AzureRM provider >= 4.0

## Notes
- All sensitive values (such as secrets and keys) are stored in Azure Key Vault.
- Role assignments are managed for secure access to resources.

---

Feel free to customize the variables and resources as needed for your ML workloads.

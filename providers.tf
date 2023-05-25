// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.
// add a provider called archive to our Terraform project. The archive provider will give us a Terraform data source for zipping Lambda function code
terraform{
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0.0"
        }
        archive = {
            source  = "hashicorp/archive"
            version = "~> 2.0.0"
        }
    }
}
provider "aws" {
    region = var.region
}
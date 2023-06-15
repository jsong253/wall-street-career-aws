variable "region" {
    type = string
    description = "The region in which to create/manage resources"
    default = "us-east-1"
}
variable "account_id"{
  type          = string
  description   = "The account ID in which to create/manage resources"
  default       = "770646514888"
}

variable "env" {
    type = string
    description = "The region in which to create/manage resources"
    default = "test"
}
variable "shared_credentials_file" {
  description = "Profile file with credentials to the AWS account"
  type        = string
  default     = "~/.aws/credentials"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default ={
    application = "wall-street-carrer"
    env         = "Test"
  }
}


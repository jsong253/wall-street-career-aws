variable "env" {
  type          = string
  description   = "The region in which to create/manage resources"
  default       = "Test"
} 

variable "billing_mode" {
  type          = string
  description   = "The aws billing method"
  default       = "PROVISIONED"
}

variable "point_in_time_recovery" {
    default       = true
}

variable "table_name" {
    default       = "registration_table"
}

variable "env" {
  type          = string
  description   = "The region in which to create/manage resources"
} 

variable "billing_mode" {
  type          = string
  description   = "The aws billing method"
}

variable "point_in_time_recovery" {
    default       = true
}

variable "feedback_table_name" {
  type          = string
  description   = "The name of the dynamodb registration table"
}

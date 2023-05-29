variable "user_pool_name" {
  type        = string
  description = "The name of the user pool"
  default     = "wall-stree-career-api-gateway-user-pool"
}
variable "user_pool_client_name" {
  type        = string
  description = "The name of the user pool client"
  default     = "wall-stree-career-api-gateway-user-pool-client"
}
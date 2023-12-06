variable "api_name" {
  type        = string
  description = "The name of the api"

}

variable "method_health" {
  default = ["GET"]
}
variable "method_product" {
  default = ["GET", "POST", "PATCH", "DELETE"]
}
variable "method_products" {
  default = ["GET"]
}

variable "lambda_function_invoke_arn" {
}

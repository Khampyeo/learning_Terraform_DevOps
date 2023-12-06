variable "function_name" {
  type        = string
  description = "The name of the Lambda function"
}
variable "role_arn" {
  type        = string
  description = "The ARN of the IAM role for Lambda"
}
variable "dynamodb_table" {
  type        = string
  description = "Dynamo Table name"
}
variable "bucket_arn" {

}

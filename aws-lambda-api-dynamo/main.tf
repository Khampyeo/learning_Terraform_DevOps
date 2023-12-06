module "iam_role" {
  source        = "./module/iam_role"
  iam_role_name = "s3_lambda"
}

module "s3" {
  source                             = "./module/s3"
  bucket_name                        = "s3-lambda-kietnc3"
  lambda_function_arn                = module.lambda.lambda_function_arn
  aws_lambda_permission_allow_bucket = module.lambda.aws_lambda_permission_allow_bucket
}

module "lambda" {
  source         = "./module/lambda"
  function_name  = "my-lambda-function"
  role_arn       = module.iam_role.role_arn
  bucket_arn     = module.s3.bucket_arn
  dynamodb_table = "my_database"
}

module "api_gateway" {
  source                     = "./module/api_gateway"
  api_name                   = "my_api"
  lambda_function_invoke_arn = module.lambda.lambda_function_invoke_arn
}

data "archive_file" "zip_code" {
  type        = "zip"
  source_dir  = "${path.module}/project/"
  output_path = "${path.module}/project/nodejs.zip"
}

module "dynamodb" {
  source     = "./module/dynamodb"
  table_name = "my_database"
}

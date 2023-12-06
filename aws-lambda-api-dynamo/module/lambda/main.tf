
resource "aws_lambda_function" "my_lambda_function" {
  filename      = "./project/nodejs.zip"
  function_name = var.function_name
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  role          = var.role_arn # Tham chiếu đến IAM role cho Lambda execution

  # tracing_config {
  #   mode = "Active"
  # }
  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.arn
  principal     = "logs.amazonaws.com"

  source_arn = aws_cloudwatch_log_group.lambda_log_group.arn
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/example-lambda"
}

output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda_function.arn
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.my_lambda_function.invoke_arn
}

output "aws_lambda_permission_allow_bucket" {
  value = aws_lambda_permission.allow_bucket
}


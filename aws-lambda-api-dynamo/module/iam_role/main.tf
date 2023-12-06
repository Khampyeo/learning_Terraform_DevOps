resource "aws_iam_role" "lambda_s3" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = var.iam_role_name
  depends_on = [aws_iam_role.lambda_s3]
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = var.iam_role_name
  depends_on = [aws_iam_role.lambda_s3]

}

resource "aws_iam_role_policy_attachment" "api_gateway_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
  role       = var.iam_role_name
  depends_on = [aws_iam_role.lambda_s3]
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = var.iam_role_name
  depends_on = [aws_iam_role.lambda_s3]

}
output "role_arn" {
  value = aws_iam_role.lambda_s3.arn
}

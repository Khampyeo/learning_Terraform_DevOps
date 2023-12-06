resource "aws_api_gateway_rest_api" "my_api" {
  name = var.api_name
}
//HEALTH
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = each.value
  authorization = "NONE"

  for_each = toset(var.method_health)

}
//PRODUCT
resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "product"
}

resource "aws_api_gateway_method" "product_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = each.value
  authorization = "NONE"

  for_each = toset(var.method_product)
}

//PRODUCTS
resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "products"
}
resource "aws_api_gateway_method" "products_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = each.value
  authorization = "NONE"

  for_each = toset(var.method_products)

}
//INTERGRATION
resource "aws_api_gateway_integration" "my_integration_health" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = each.value
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn

  for_each = toset(var.method_health)
}
resource "aws_api_gateway_integration" "my_integration_product" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = each.value
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn

  for_each = toset(var.method_product)

}
resource "aws_api_gateway_integration" "my_integration_products" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.products.id
  http_method             = each.value
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn

  for_each = toset(var.method_products)
}
//DEPLOY
// cách 1
# resource "aws_api_gateway_deployment" "my_deployment" {
#   depends_on = [aws_api_gateway_integration.my_integration, aws_api_gateway_method.my_method]

#   rest_api_id = aws_api_gateway_rest_api.my_api.id
#   stage_name  = "dev"
# }

//cách 2
resource "aws_api_gateway_stage" "dev_stage" {
  deployment_id = aws_api_gateway_deployment.my_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "dev"

  lifecycle {
    ignore_changes = [stage_name]
  }
}

resource "aws_api_gateway_deployment" "my_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.my_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_method.health_method, aws_api_gateway_method.product_method,
    aws_api_gateway_method.products_method, aws_api_gateway_integration.my_integration_products,
  aws_api_gateway_integration.my_integration_health, aws_api_gateway_integration.my_integration_product]

}

resource "aws_dynamodb_table" "my-dynamodb-table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "Id"
  range_key      = "name"

  attribute {
    name = "Id"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  #   ttl {
  #     attribute_name = "TimeToExist"
  #     enabled        = false
  #   }

  tags = {
    Name        = "dynamodb-table"
    Environment = "dev"
  }

}

 resource "aws_dynamodb_table" "link_table" {
  name           = "Links"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "processed"
  range_key      = "original"

  attribute {
    name = "processed"
    type = "S"
  }

  attribute {
    name = "original"
    type = "S"
  }
}

resource "aws_dynamodb_table" "clicks_table" {
  name           = "Clicks"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "processed"
  range_key      = "timestamp"

  attribute {
    name = "processed"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}
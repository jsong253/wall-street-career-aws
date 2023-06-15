// https://dynobase.dev/dynamodb-terraform/
resource "aws_kms_key" "dynamo_kms_key" {
  description = "Encryption key for dynamo"
  enable_key_rotation = true
}


resource "aws_kms_alias" "dynamo_kms_alias" {
  name = "alias/dynamo-key-${var.env}-alias"
  target_key_id = aws_kms_key.dynamo_kms_key.key_id
}

resource "aws_dynamodb_table" "registration_table" {
  name = "${var.table_name}-${var.env}"
  billing_mode = var.billing_mode               // PROVISIONED or "PAY_PER_REQUEST"
  hash_key = "ID"
  read_capacity           = 5
  write_capacity          = 5

  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "ID"
    type = "S"
  }

  # attribute {
  #   name = "email"
  #   type = "S"
  # }

  # attribute {
  #   name = "phone"
  #   type = "S"
  # }

  # attribute {
  #   name = "firstName"
  #   type = "S"
  # }

  # attribute {
  #   name = "lastName"
  #   type = "S"
  # }  

  # attribute {
  #   name = "expiryPeriod"
  #   type = "N"
  # }

  # attribute {
  #   name = "password"
  #   type = "S"
  # }

  attribute {
    name = "startTime"
    type = "S"
  }

   attribute {
    name = "createdAt"
    type = "N"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "registrationType"
    type = "S"
  }

  global_secondary_index {
    name = "CreatedAtIndex"
    hash_key = "createdAt"
    range_key = "status"
    projection_type = "ALL"
    read_capacity           = 5           
    write_capacity          = 5             // must define write capacityotherwise you get: failed to create GSI: write capacity must be > 0 when billing mode is PROVISIONED
  }

  global_secondary_index {
    name = "RegistrationType"
    hash_key = "registrationType"
    range_key = "startTime"
    projection_type = "ALL"
    read_capacity           = 5
    write_capacity          = 5           // must define write capacityotherwise you get: failed to create GSI: write capacity must be > 0 when billing mode is PROVISIONED
  }

  ttl {
    attribute_name = "expiryPeriod"
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  //  prevent Terraform from removing your scaling actions
  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
  }

  server_side_encryption {
    enabled = "true"
    kms_key_arn = aws_kms_key.dynamo_kms_key.arn
  }
}

module  "table_autoscaling" { 
   source = "snowplow-devops/dynamodb-autoscaling/aws" 
   table_name = aws_dynamodb_table.registration_table.name
}
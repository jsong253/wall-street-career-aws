// https://dynobase.dev/dynamodb-terraform/
// https://medium.com/@jun711.g/how-to-set-time-to-live-attribute-for-amazon-dynamodb-entries-6b10ed16281#:~:text=Open%20up%20your%20AWS%20console,TTL%20button%20next%20to%20it.


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
    type = "N"
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

  // The TTL attribute’s value must be a timestamp in Unix epoch time format in seconds. If you use any other format, the TTL processes ignore the item. For example, if you set the value of the attribute to 1645119622, that is Thursday, February 17, 2022 17:40:22 (GMT), the item will be expired after that time.
  // https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/time-to-live-ttl-before-you-start.html
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

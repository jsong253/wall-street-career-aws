// setup dynamodb table, lambdas for CRUD and State Locking in Terraform
// https://dynobase.dev/dynamodb-terraform/


// https://medium.com/@jun711.g/how-to-set-time-to-live-attribute-for-amazon-dynamodb-entries-6b10ed16281#:~:text=Open%20up%20your%20AWS%20console,TTL%20button%20next%20to%20it.

// https://repost.aws/knowledge-center/lambda-kmsaccessdeniedexception-errors

resource "aws_kms_key" "dynamo_kms_key_feedback" {
  description = "Encryption key for dynamodb feedback table"
  enable_key_rotation = true
}


resource "aws_kms_alias" "dynamo_kms_alias_feedback" {
  name = "alias/dynamo-key-${var.env}-alias-feedback"
  target_key_id = aws_kms_key.dynamo_kms_key_feedback.key_id
}

resource "aws_dynamodb_table" "feedback_table" {
  name = "${var.feedback_table_name}-${var.env}"
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

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "phone"
    type = "S"
  }

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
  // name index with attribute name plus sufix 'Index'
  global_secondary_index {
    name = "StatusIndex"
    hash_key = "status"
    range_key = "createdAt"
    projection_type = "ALL"
    read_capacity           = 5           
    write_capacity          = 5             // must define write capacityotherwise you get: failed to create GSI: write capacity must be > 0 when billing mode is PROVISIONED
  }


  global_secondary_index {
    name = "emailIndex"
    hash_key = "email"
    range_key = "createdAt"
    projection_type = "ALL"
    read_capacity           = 5
    write_capacity          = 5           // must define write capacityotherwise you get: failed to create GSI: write capacity must be > 0 when billing mode is PROVISIONED
  }


  global_secondary_index {
    name = "phoneIndex"
    hash_key = "phone"
    range_key = "createdAt"
    projection_type = "ALL"
    read_capacity           = 5
    write_capacity          = 5           // must define write capacityotherwise you get: failed to create GSI: write capacity must be > 0 when billing mode is PROVISIONED
  }


  global_secondary_index {
    name = "registrationTypeIndex"
    hash_key = "registrationType"
    range_key = "status"
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
    // false -> use AWS Owned CMK 
    // true -> use AWS Managed CMK 
    // true + key arn -> use custom key
    kms_key_arn = aws_kms_key.dynamo_kms_key_feedback.arn
  }

   tags = {
    Name        = "${var.feedback_table_name}-${var.env}"
    Environment = "production"
  }
}

// For tables on the PROVISIONED billing mode, you can configure auto-scaling so that DynamoDB scales up to 
// adjust the provisioned capacity based on traffic patterns.

// https://registry.terraform.io/modules/snowplow-devops/dynamodb-autoscaling/aws/latest
module  "table_autoscaling" { 
   source = "snowplow-devops/dynamodb-autoscaling/aws" 
   table_name = aws_dynamodb_table.feedback_table.name
}

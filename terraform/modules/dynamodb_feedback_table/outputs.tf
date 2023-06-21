output "feedback_table_id" {
    description = "Name of the table"
    value = aws_dynamodb_table.feedback_table.id
}
 
output "feedback_table_arn" {
    description = "ARN of the table"
    value = aws_dynamodb_table.feedback_table.arn
}

output "feedback_table_stream_arn" {
    description ="The ARN of the Table Stream. Only available when stream_enabled = true"
    value =  join("", aws_dynamodb_table.feedback_table.*.stream_arn)
}

output "feedback_table_stream_label" {
    description ="A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true"
    value =  join("", aws_dynamodb_table.feedback_table.*.stream_label)
}

output "dynamo_kms_key_arn" {
    description ="The ARN of the dynamo kms key for feedback table"
    value = aws_kms_key.dynamo_kms_key_feedback.arn
}

# output "dynamodb_kms_key_arn" {
#     description ="A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true"
#     value =  "${aws_dynamodb_table.dynamo_kms_key.arn}"
# }
# EventBridge event rule for daily_lambda trigger
resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "daily_trigger"
  description         = "Fires an event daily for daily_lambda"
  schedule_expression = "rate(1 day)"
}
# Sets event target to daily_lambda
resource "aws_cloudwatch_event_target" "check_lambda_every_day" {
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = "lambda"
  arn       = module.daily_lambda.lambda_function_arn
}
# Sets permission for event to invoke daily_lambda
resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.daily_lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}


# SQS queue for analysis_lambda trigger
resource "aws_sqs_queue" "queue" {
  name   = "dq-event-notification-queue"
  policy = <<POLICY
  {
  "Version": "2008-10-17",
  "Id": "example-ID",
  "Statement": [
    {
      "Sid": "example-statement-ID",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:*",
      "Resource": "arn:aws:sqs:*:*:dq-event-notification-queue",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "803471918786"
        },
        "ArnLike": {
          "aws:SourceArn": "${module.s3_bucket.s3_bucket_arn}"
        }
      }
    }
  ]
}
  POLICY
}
# Event notification from S3 to SQS on file update
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3_bucket.s3_bucket_id
  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "population"
    filter_suffix = ".json"
  }
}
# Setting SQS as a trigger for analysis_lambda
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  enabled          = true
  function_name    = module.analysis_lambda.lambda_function_name
}

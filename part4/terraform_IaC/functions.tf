# Daily-running lambda function that syncs API data with S3 bucket data
module "daily_lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "daily_lambda"
  description   = "Runs daily to sync API data with S3 bucket"
  handler       = "daily_lambda.lambda_handler"
  runtime       = "python3.9"
  publish       = true
  timeout       = 300
  memory_size = 1024
  ephemeral_storage_size = 512

  create_package         = false
  local_existing_package = "./scripts/daily_lambda.zip"

  attach_policy_statements = true
  policy_statements = {
    s3_bucket_access = {
      effect    = "Allow",
      actions   = ["*"],
      resources = ["*"]
    }
  }
  environment_variables = {
    S3_BUCKET_NAME = "${module.s3_bucket.s3_bucket_id}"
  }

  tags = {
    Name = "Daily API Sync Lambda Function"
  }
}

# Analysis lambda function that reports analysis data to Cloudwatch Logs
module "analysis_lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "analysis_lambda"
  description   = "Runs analysis on stored API data from S3 bucket"
  handler       = "analysis_lambda.lambda_handler"
  runtime       = "python3.9"
  publish       = true
  timeout       = 300
  memory_size = 1024
  ephemeral_storage_size = 512

  attach_policy_statements = true
  policy_statements = {
    sqs = {
      effect    = "Allow",
      #actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
      actions = ["*"]
      #resources = ["${aws_sqs_queue.queue.arn}"]
      resources = ["*"]
    }
  }

  create_package         = false
  local_existing_package = "./scripts/analysis_lambda.zip"
  environment_variables = {
    S3_BUCKET_NAME = "${module.s3_bucket.s3_bucket_id}"
  }

  tags = {
    Name = "Data Analysis Lambda Function"
  }
}

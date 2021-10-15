provider "aws" {
  
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    cloudwatchlogs   = "http://localhost:4566"
    cloudwatchevents = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "test-bucket" {
  bucket = "my-bucket"
}


module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "my-lambda1"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  source_path = "../app"

  tags = {
    Name = "my-lambda1"
  }

  event_source_mapping = {
    sqs1 = {
      event_source_arn = aws_sqs_queue.this.arn
    }
  }

  #allowed_triggers = {
  #  sqs2 = {
  #    principal  = "sqs.amazonaws.com"
  #    source_arn = aws_sqs_queue.this.arn
  #  }
  #}

  #attach_policy_statements = true
  #policy_statements = {
  #  # Allow failures to be sent to SQS queue
  #  sqs_failure = {
  #    effect    = "Allow",
  #    actions   = ["sqs:SendMessage"],
  #    resources = [aws_sqs_queue.failure.arn]
  #  },
  #}
}

# SQS
resource "random_pet" "this" {
  length = 2
}

resource "aws_sqs_queue" "this" {
  name = random_pet.this.id
}

resource "aws_sqs_queue" "failure" {
  name = "${random_pet.this.id}-failure"
}

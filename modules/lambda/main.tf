resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "post_lambda" {
  s3_bucket         = "${var.s-3}"
  s3_object_version = "${var.s-3-object-post}"
  s3_key            = "${var.s-3-key-post}"
  function_name     = "HelloLambdaPost"
  role              = "${aws_iam_role.iam_for_lambda.arn}"
  handler           = "com.amazonaws.lambda.demo.HelloLambda"

  runtime = "java8"
  timeout = "55"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}

resource "aws_lambda_function" "get_lambda" {
  s3_bucket         = "${var.s-3}"
  s3_object_version = "${var.s-3-object-get}"
  s3_key            = "${var.s-3-key-get}"
  function_name     = "HelloLambdaGet"
  role              = "${aws_iam_role.iam_for_lambda.arn}"
  handler           = "com.amazonaws.lambda.demo.LambdaFunctionHandler"

  runtime = "java8"
  timeout = "55"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}

data "aws_caller_identity" "current" {}

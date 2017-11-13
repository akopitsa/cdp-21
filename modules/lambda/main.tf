resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com",
          "s3.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda-policy" {
  name = "test-policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "basic-exec-role" {
  role = "${aws_iam_role.iam_for_lambda.name}"

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

  #policy_arn = "arn:aws:iam::aws:policy/service-role/AdministratorAccess"
}

data "aws_iam_policy_document" "s3-access-ro" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_policy" "s3-access-ro" {
  name   = "s3-access-ro"
  path   = "/"
  policy = "${data.aws_iam_policy_document.s3-access-ro.json}"
}

resource "aws_iam_role_policy_attachment" "s3-access-ro" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.s3-access-ro.arn}"
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

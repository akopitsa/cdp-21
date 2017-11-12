# OUTPUT TF LAMBDA

output "lambda-post-arn" {
  value = "${aws_lambda_function.post_lambda.arn}"
}

output "lambda-get-arn" {
  value = "${aws_lambda_function.get_lambda.arn}"
}

output "lambda-post-function" {
  value = "${aws_lambda_function.post_lambda.function_name}"
}

output "lambda-get-function" {
  value = "${aws_lambda_function.get_lambda.function_name}"
}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

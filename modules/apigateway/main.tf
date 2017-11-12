# MAIN TF API Gateway

resource "aws_api_gateway_rest_api" "api" {
  name = "AutoApiGW"
}

resource "aws_api_gateway_resource" "add" {
  path_part   = "add"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_resource" "show" {
  path_part   = "show"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method-get" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.show.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "method-post" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.add.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration-add" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.add.id}"
  http_method             = "${aws_api_gateway_method.method-post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda-post-function}"
}

resource "aws_api_gateway_integration" "integration-show" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.show.id}"
  http_method             = "${aws_api_gateway_method.method-get.http_method}"
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda-get-function}"
}

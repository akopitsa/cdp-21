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

  # request_parameters {
  #   "integration.request.path.id" = "method.request.path.accountId"
  # }
  request_parameters = {
    #"method.request.header.X-Some-Header" = true
    "method.request.querystring.name" = ""
  }

  # request_models = {
  #   "application/json" = "Empty"
  # }
}

resource "aws_api_gateway_method" "method-post" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.add.id}"
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    #"method.request.header.X-Some-Header" = true
    "method.request.querystring.name" = true
    "method.request.querystring.time" = true
  }
}

resource "aws_api_gateway_integration" "integration-add" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.add.id}"
  http_method = "${aws_api_gateway_method.method-post.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda-post-arn}/invocations"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
    {
       "name": "$input.params('name')",
       "time": "$input.params('time')"
    }
EOF
  }
}

resource "aws_api_gateway_integration" "integration-show" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.show.id}"
  http_method = "${aws_api_gateway_method.method-get.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda-get-arn}/invocations"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
    {
       "name": "$input.params('name')"
    }
EOF
  }
}

resource "aws_api_gateway_method_response" "get200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.show.id}"
  http_method = "${aws_api_gateway_method.method-get.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "post200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.add.id}"
  http_method = "${aws_api_gateway_method.method-post.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "GetIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.show.id}"
  http_method = "${aws_api_gateway_method.method-get.http_method}"
  status_code = "${aws_api_gateway_method_response.get200.status_code}"
  depends_on  = ["aws_api_gateway_integration.integration-show"]

  # Transforms the backend JSON response to JSON
  response_templates {
    "application/json" = <<EOF
EOF
  }
}

resource "aws_api_gateway_integration_response" "PostIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.add.id}"
  http_method = "${aws_api_gateway_method.method-post.http_method}"
  status_code = "${aws_api_gateway_method_response.post200.status_code}"
  depends_on  = ["aws_api_gateway_integration.integration-add"]

  # Transforms the backend JSON response to JSON
  response_templates {
    "application/json" = <<EOF
    {
       "name": "$input.params('name')",
       "time": "$input.params('time')"
    }
EOF
  }
}

resource "aws_lambda_permission" "apigw_lambdaGet" {
  statement_id  = "AllowExecutionFromAPIGatewayGet2017"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda-get-function}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method-get.http_method}${aws_api_gateway_resource.show.path}"
}

resource "aws_lambda_permission" "apigw_lambdaPost" {
  statement_id  = "AllowExecutionFromAPIGatewayPost2017"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda-post-function}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method-post.http_method}${aws_api_gateway_resource.add.path}"
}

resource "aws_api_gateway_deployment" "APIDeployment" {
  depends_on  = ["aws_api_gateway_integration_response.GetIntegrationResponse", "aws_api_gateway_integration_response.GetIntegrationResponse"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "beta"
}

output "post_url" {
  value = "https://${aws_api_gateway_deployment.APIDeployment.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.HelloWorldAPIDeployment.stage_name}/add?name=Petya&time=12:25"
}

output "get_url" {
  value = "https://${aws_api_gateway_deployment.APIDeployment.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.HelloWorldAPIDeployment.stage_name}/show?name=Petya"
}

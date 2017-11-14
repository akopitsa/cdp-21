output "post_url" {
  value = "https://${aws_api_gateway_deployment.APIDeployment.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.APIDeployment.stage_name}/add?name=Petya&time=12:25"
}

output "get_url" {
  value = "https://${aws_api_gateway_deployment.APIDeployment.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.APIDeployment.stage_name}/show?name=Petya"
}

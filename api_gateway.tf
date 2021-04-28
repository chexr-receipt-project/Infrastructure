resource "aws_api_gateway_rest_api" "cherx_api" {
  name        = "cherx_api"
  description = "Cherx Receipts API"
}


resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.cherx_api.id
   parent_id   = aws_api_gateway_rest_api.cherx_api.root_resource_id
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.cherx_api.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "COGNITO_USER_POOLS"
   authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.cherx_api.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.cherx_dev.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
   depends_on = [
     aws_api_gateway_integration.lambda
   ]

   rest_api_id = aws_api_gateway_rest_api.cherx_api.id
   stage_name  = "dev"
}

output "base_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}


resource aws_api_gateway_authorizer "authorizer" {
   name                   = "authorizer"
   rest_api_id            = aws_api_gateway_rest_api.cherx_api.id
   # authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
   # authorizer_credentials = aws_iam_role.invocation_role.arn
   type = "COGNITO_USER_POOLS"
   provider_arns = [aws_cognito_user_pool.test_chexr.arn]
}

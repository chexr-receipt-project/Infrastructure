variable "lambda_function_name" {
  default = "cherx_dev_api"
}


resource "aws_lambda_function" "cherx_dev" {
   function_name = var.lambda_function_name
   tags = {
    Environment = "development"
   }


   s3_bucket = aws_s3_bucket.files.bucket
   s3_key    = var.lambda_function_source_key
   runtime = var.lambda_function_runtime
   handler = "function_api/main.handler"

   role = aws_iam_role.lambda_exec_dev.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

}


resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.cherx_dev.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.cherx_api.execution_arn}/*/*"
}
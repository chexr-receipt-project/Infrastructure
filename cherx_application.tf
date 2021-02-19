resource "aws_lambda_function" "cherx_dev" {
   function_name = "cherx_dev"

   s3_bucket = aws_s3_bucket.files.bucket
   s3_key    = "source/dev_1.zip"
   handler = "main.handler"
   runtime = "python3.8"

   role = aws_iam_role.lambda_exec_dev.arn
}

resource "aws_iam_role" "lambda_exec_dev" {
   name = "cherx_dev"

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

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.cherx_dev.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.cherx_api.execution_arn}/*/*"
}
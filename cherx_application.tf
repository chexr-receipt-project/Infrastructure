variable "lambda_function_name" {
  default = "cherx_dev"
}


resource "aws_lambda_function" "cherx_dev" {
   function_name = var.lambda_function_name
   tags = {
    Environment = "development"
   }


   s3_bucket = aws_s3_bucket.files.bucket
   s3_key    = "source/dev_1.zip"
   handler = "main.handler"
   runtime = "python3.8"

   role = aws_iam_role.lambda_exec_dev.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

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


# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_dev.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "matching_queue_send_and_receive" {
  name        = "matching_queue_send_and_receive"
  path        = "/"
  description = "IAM policy to enable sending and receiving messages for the matching queue"
  
  policy = format(<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage"
      ],
      "Resource": "${aws_sqs_queue.matching_queue.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
)
}

resource "aws_iam_role_policy_attachment" "matching_queue_send_and_receive" {
  role       = aws_iam_role.lambda_exec_dev.name
  policy_arn = aws_iam_policy.matching_queue_send_and_receive.arn
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
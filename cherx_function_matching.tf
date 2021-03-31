variable "lambda_function_matching_name" {
  default = "cherx_dev_matching"
}


resource "aws_lambda_function" "cherx_dev_matching" {
   function_name = var.lambda_function_matching_name
   tags = {
    Environment = "development"
   }


   s3_bucket = aws_s3_bucket.files.bucket
   s3_key    = var.lambda_function_source_key
   runtime = var.lambda_function_runtime
   handler = "function_matching/main.handler"

   role = aws_iam_role.lambda_exec_dev.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

}

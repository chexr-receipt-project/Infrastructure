variable "lambda_function_send_receipt_name" {
  default = "cherx_dev_send_receipt"
}


resource "aws_lambda_function" "lambda_function_send_receipt" {
   function_name = var.lambda_function_send_receipt_name
   tags = {
    Environment = "development"
   }


   s3_bucket = aws_s3_bucket.files.bucket
   s3_key    = var.lambda_function_source_key
   runtime = var.lambda_function_runtime
   handler = "function_send_bank_receipt/main.handler"
   

   role = aws_iam_role.lambda_exec_dev.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

}

resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "every-one-minute"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_one_minute" {
  rule      = "${aws_cloudwatch_event_rule.every_one_minute.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.lambda_function_send_receipt.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function_send_receipt.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_one_minute.arn}"
}
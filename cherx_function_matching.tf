variable "lambda_function_matching_name" {
  default = "cherx_matching"
}


resource "aws_lambda_function" "cherx_matching" {
   function_name = var.lambda_function_matching_name

   s3_bucket = aws_s3_bucket.files.bucket
   s3_key    = aws_s3_bucket_object.initial_source_file.key
   runtime = var.lambda_function_runtime
   handler = "function_matching/main.handler"

   role = aws_iam_role.lambda_exec.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  vpc_config {
    subnet_ids = module.vpc.private_subnets
    security_group_ids = ["${aws_security_group.service.id}"]
  }

  environment {
    variables = {
      MONGO_URL = "mongodb://${aws_docdb_cluster.service.master_username}:${aws_docdb_cluster.service.master_password}@${aws_docdb_cluster.service.endpoint}:${aws_docdb_cluster.service.port}/?retryWrites=false"
      PROJECT_NAME = var.name
      MONGO_DATABASE = var.mongo_db_name
      MATCHING_QUEUE_URL = aws_sqs_queue.matching_queue.id
    }
  }

}


resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.matching_queue.arn
  function_name    = aws_lambda_function.cherx_matching.arn
}
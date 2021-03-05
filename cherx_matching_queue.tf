resource "aws_sqs_queue" "matching_queue" {
  name                      = "matching_queue"
  max_message_size          = 1024
  tags = {
    Environment = "development"
  }
}


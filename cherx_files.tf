resource "aws_s3_bucket" "files" {
    bucket = "cherx-files"
    acl    = "private"
}
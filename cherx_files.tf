resource "aws_s3_bucket" "files" {
    bucket = "cherxfiles"
    acl    = "private"
    force_destroy = true
    versioning {
        enabled = true
        mfa_delete = false      
    }
}

resource "aws_s3_bucket_object" "initial_source_file" {
    bucket = aws_s3_bucket.files.id
    key = var.lambda_function_source_key
    source = "files/default_source.zip"
    etag = filemd5("files/default_source.zip")
}
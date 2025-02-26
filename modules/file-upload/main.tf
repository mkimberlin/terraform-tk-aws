# Create a randomly named S3 bucket to hold uploaded files
resource "random_id" "file-upload-hash" {
  byte_length = 8
}

resource "aws_s3_bucket" "file-upload" {
  bucket  = "file-upload-${random_id.file-upload-hash.hex}"
  tags    = {
    Description  = "A bucket for use for uploading files by members of a specific group."
  }
}

# Users to be placed in the file-upload-group
resource "aws_iam_user" "file-upload-user1" {
  name  = "bettybaboon"
  tags  = {
    Description = "An example file upload user"
  }
}

resource "aws_iam_user" "file-upload-user2" {
  name  = "cindycat"
  tags  = {
    Description = "Another example file upload user"
  }
}

# A group to hold users that are authorized to perform file uploads
resource "aws_iam_group" "file-upload-group" {
  name  = "file-upload-group"
}

# Membership definition for the file upload group
resource "aws_iam_group_membership" "file-uploaders" {
  name = "file-uploaders"

  users = [
    aws_iam_user.file-upload-user1.name,
    aws_iam_user.file-upload-user2.name,
  ]

  group = aws_iam_group.file-upload-group.name
}

# Create a policy from a template file that only allows write access
# to a specific S3 bucket. The ARN for the bucket is provided via the
# "bucket-arn" property.
resource "aws_iam_policy" "upload-only-policy" {
  name    = "file-upload-only"
  policy  = templatefile("${path.module}/policies/file-upload-write-only.policy.tftpl", { bucket-arn: aws_s3_bucket.file-upload.arn })
}

# Attach the read only policy for the bucket to the file-upload-group
resource "aws_iam_group_policy_attachment" "upload-only-policy-attachment" {
  group      = aws_iam_group.file-upload-group.name
  policy_arn = aws_iam_policy.upload-only-policy.arn
}

# Create an execution role for the lambda responsible for reading uploaded files
resource "aws_iam_role" "file-upload-reader" {
  name = "file-upload-reader"
  assume_role_policy = file("${path.module}/policies/lambda-may-assume-role.policy.json")
}

# Create an inline role policy from a template file that only allows read access
# to the file-upload S3 bucket. The ARN for the bucket is again provided
# via the "bucket-arn" property.
resource "aws_iam_role_policy" "file-upload-reader-policy" {
  name    = "file-upload-reader-policy"
  role    = aws_iam_role.file-upload-reader.id
  policy  = templatefile("${path.module}/policies/file-upload-lambda.policy.tftpl", { bucket-arn: aws_s3_bucket.file-upload.arn })
}

data "archive_file" "lambda-archive" {
  type        = "zip"
  source_file = "${path.module}/lambdas/file-upload.mjs"
  output_path = "${path.module}/dist/lambda_function_payload.zip"
}

# Create a lambda to process any new objects from the S3 bucket
resource "aws_lambda_function" "file-upload-reader" {
  # If the file is not in the current working directory you will need to include a
  # path. module in the filename.
  filename      = "${path.module}/dist/lambda_function_payload.zip"
  function_name = var.lambda-function-name
  role          = aws_iam_role.file-upload-reader.arn
  source_code_hash = data.archive_file.lambda-archive.output_base64sha256
  runtime = "nodejs22.x"
  handler = "file-upload.handler"
  depends_on    = [aws_cloudwatch_log_group.file-upload-reader]

  environment {
    variables = {
      # "SQS_QUEUE_URL" = aws_sqs_queue...
    }
  }
}

# Create a log group for the file-upload-reader lambda to use
resource "aws_cloudwatch_log_group" "file-upload-reader" {
  name              = "/aws/lambda/${var.lambda-function-name}"
  retention_in_days = 7
  skip_destroy = false
}

resource "aws_s3_bucket_notification" "file-upload-reader-trigger" {
  bucket = aws_s3_bucket.file-upload.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file-upload-reader.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "file-upload-invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file-upload-reader.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.file-upload.arn
}
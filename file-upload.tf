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

resource "aws_iam_group" "file-upload-group" {
  name  = "file-upload-group"
}

resource "aws_iam_group_membership" "file-uploaders" {
  name = "file-uploaders"

  users = [
    aws_iam_user.file-upload-user1.name,
    aws_iam_user.file-upload-user2.name,
  ]

  group = aws_iam_group.file-upload-group.name
}

resource "aws_iam_policy" "upload-only-policy" {
  name    = "FileUploadOnly"
  policy  = templatefile("${path.module}/policies/file-upload-write-only.policy.tftpl", { bucket-arn: aws_s3_bucket.file-upload.arn })
}

resource "aws_iam_group_policy_attachment" "upload-only-policy-attachment" {
  group      = aws_iam_group.file-upload-group.name
  policy_arn = aws_iam_policy.upload-only-policy.arn
}

resource "random_id" "file-upload-hash" {
  byte_length = 8
}

resource "aws_s3_bucket" "file-upload" {
  bucket  = "file-upload-${random_id.file-upload-hash.hex}"
  tags    = {
    Description  = "A bucket for use for uploading files by members of a specific group."
  }
}

# Establish a budget and notification to let us know if we spend even a cent
resource "aws_budgets_budget" "no-money" {
  name          = "no-money"
  budget_type   = "COST"
  limit_amount  = "0.01"
  limit_unit    = "USD"
  time_unit     = "MONTHLY"

  notification {
    comparison_operator        = "EQUAL_TO"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_notification_recipients
  }
}

# Establish a S3 bucket for the Terraform Backend of the main module
resource "random_id" "state-bucket-hash" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform-state" {
  bucket        = "tfstate-${random_id.state-bucket-hash.hex}"
  force_destroy = true
  tags          = {
    Description  = "A bucket for use for holding the shared Terraform state."
  }
}

resource "aws_s3_bucket_versioning" "terraform-state-versioning" {
  bucket = aws_s3_bucket.terraform-state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "local_file" "backend-config" {
  content  = templatefile("${path.module}/templates/backend.tf.tftpl", {
    bucket  = aws_s3_bucket.terraform-state.bucket
    region  = var.region
    key     = "terraform-tk-aws/tfstate"
  } )
  filename = "${path.module}/../backend.tf"
}
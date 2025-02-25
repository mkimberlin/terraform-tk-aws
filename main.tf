# Ensure that all users have MFA enabled, but allow self-management
# of various other credentials
module enforce_mfa {
  source  = "terraform-module/enforce-mfa/aws"
  version = "~> 1.0"

  policy_name                     = "managed-mfa-enforce"
  manage_own_signing_certificates  = true
  manage_own_ssh_public_keys      = true
  manage_own_git_credentials      = true
}

# Create admin resources
module "admin" {
  source  = "./admin"
}

# Create file upload system resources
module "file-upload" {
  source  = "./file-upload"
}

# Establish a budget and notification to let us know if we spend even a cent
resource "aws_budgets_budget" "no-money" {
  name              = "no-money"
  budget_type       = "COST"
  limit_amount      = "0.01"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "EQUAL_TO"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_notification_recipients
  }
}

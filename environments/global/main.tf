# Ensure that all users have MFA enabled, but allow self-management
# of various other credentials
module enforce_mfa {
  source  = "terraform-module/enforce-mfa/aws"
  version = "~> 1.0"

  policy_name                     = "managed-mfa-enforce"
  manage_own_signing_certificates = true
  manage_own_ssh_public_keys      = true
  manage_own_git_credentials      = true
}

#Create global file upload drop and processing
module "file-upload" {
  source = "../../modules/file-upload"
  region = var.default_region
}
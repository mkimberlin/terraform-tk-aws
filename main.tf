module enforce_mfa {
  source  = "terraform-module/enforce-mfa/aws"
  version = "~> 1.0"

  policy_name                     = "managed-mfa-enforce"
  manage_own_signing_certificates  = true
  manage_own_ssh_public_keys      = true
  manage_own_git_credentials      = true
}

resource "aws_iam_user" "admin-user" {
  name  = "aliceadmin"
  tags  = {
    Description = "An example admin user"
  }
}

resource "aws_iam_group" "admin-group" {
  name  = "admin-group"
}

resource "aws_iam_group_membership" "admins" {
  name = "admins"

  users = [
    aws_iam_user.admin-user.name,
  ]

  group = aws_iam_group.admin-group.name
}

data "aws_iam_policy" "admin-policy" {
  name  = "AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "admin-policy-attachment" {
  group      = aws_iam_group.admin-group.name
  policy_arn = data.aws_iam_policy.admin-policy.arn
}

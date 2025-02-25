# A user to be placed in the admin-group
resource "aws_iam_user" "admin-user" {
  name  = "aliceadmin"
  tags  = {
    Description = "An example admin user"
  }
}

# A group to hold admin users
resource "aws_iam_group" "admin-group" {
  name  = "admin-group"
}

# Membership definition for the admin-group
resource "aws_iam_group_membership" "admins" {
  name = "admins"

  users = [
    aws_iam_user.admin-user.name,
  ]

  group = aws_iam_group.admin-group.name
}

# Create a reference to the AWS managed admin policy
data "aws_iam_policy" "admin-policy" {
  name  = "AdministratorAccess"
}

# Attach the AWS managed admin policy to the admin-group
resource "aws_iam_group_policy_attachment" "admin-policy-attachment" {
  group      = aws_iam_group.admin-group.name
  policy_arn = data.aws_iam_policy.admin-policy.arn
}

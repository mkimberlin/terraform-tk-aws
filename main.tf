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

resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = aws_iam_group.admin-group.name
  policy_arn = data.aws_iam_policy.admin-policy.arn
}
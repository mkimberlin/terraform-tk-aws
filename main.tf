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
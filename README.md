# terraform-tk-aws
A test kitchen of terraform code for AWS

## Required Variables
The following variables do not have defaults and must be defined by the user:
 * ```budget_notification_recipients``` - **list(string)** - The list of email addresses that should be notified if the budget is exceeded
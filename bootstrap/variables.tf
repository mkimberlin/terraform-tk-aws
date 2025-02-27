variable "region" {
  type        = string
  description = "The default region into which the bootstrap resources should be created"
  default     = "us-east-2"
}

variable "budget_notification_recipients" {
  type        = set(string)
  description = "The email addresses of those people who should get notified of budget alerts"
}
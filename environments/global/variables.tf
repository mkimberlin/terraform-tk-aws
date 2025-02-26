variable "default_region" {
  type        = string
  description = "The default region into which resources should be created, when not environment specific"
}

variable "budget_notification_recipients" {
  type        = set(string)
  description = "The email addresses of those people who should get notified of budget alerts"
}

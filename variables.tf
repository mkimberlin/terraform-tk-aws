variable "default_region" {
  type        = string
  description = "The default region into which resources should be created, when not environment specific"
  default     = "us-east-2"
}

variable "environments" {
  type        = set(string)
  description = "The environment modules to be deployed"
  default     = ["development/us"]
}

variable "budget_notification_recipients" {
  type        = set(string)
  description = "The email addresses of those people who should get notified of budget alerts"
}
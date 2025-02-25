variable "default_region" {
  type        = string
  description = "The default region into which resources will be deployed"
  default     = "us-east-2"
}

variable "default_timezone" {
  type        = string
  description = "The default time zone to be used"
  default     = "America/Chicago"
}

variable "budget_notification_recipients" {
  type        = list(string)
  description = "The email addresses of those people who should get notified"
  default = []
}
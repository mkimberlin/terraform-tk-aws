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
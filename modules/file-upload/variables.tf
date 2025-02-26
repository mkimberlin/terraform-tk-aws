variable "region" {
  type        = string
  description = "The region into which resources should be deployed, when applicable"
}

variable "lambda-function-name" {
  type        = string
  description = "The name to be used for lambda function responsible for reacting to new file uploads"
  default     = "file-upload-reader"
}

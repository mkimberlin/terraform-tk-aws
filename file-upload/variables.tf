variable "lambda-function-name" {
  type        = string
  description = "The name to be used for lambda function responsible for reacting to new file uploads"
  default     = "file-upload-reader"
}

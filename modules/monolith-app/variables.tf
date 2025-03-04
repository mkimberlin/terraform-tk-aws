variable "subnet_id" {
  type        = string
  description = "The subnet into which the application server(s) should be deployed"
}

variable "app_server_ip" {
  type        = string
  description = "The IP to assign to the application server"
}

variable "ami" {
  type        = string
  description = "The AMI to use when configuring the application server(s)"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use for the application server(s)"
}

variable "region" {
  type        = string
  description = "The region into which resources should be deployed, when applicable"
}

variable "project_name" {
  description = "Name of the Terraform project"
  type        = string
  default     = "terraform-multitier"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Two Availability Zones in the selected AWS region"
  type        = list(string)

  default = [
    "ap-southeast-1a",
    "ap-southeast-1b"
  ]

  validation {
    condition     = length(var.availability_zones) == 2 && var.availability_zones[0] != var.availability_zones[1]
    error_message = "Provide exactly two different Availability Zones."
  }
}

variable "instance_type" {
  description = "EC2 instance type for web and application tiers"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_password" {
  description = "Existing RDS MySQL master password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "The RDS password must contain at least 8 characters."
  }
}

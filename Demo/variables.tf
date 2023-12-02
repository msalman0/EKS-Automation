variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "192.168.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

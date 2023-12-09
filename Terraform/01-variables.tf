variable "project" {
  description = "Project Name"
  default     = "EKS-Automation-TF"
}

variable "environment" {
  description = "Environment"
  default     = "dev"
}
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


## EC2 Bastion Host Variables
variable "ec2-bastion-public-key-path" {
  description = "ec2-bastion-public-key-path"
  default     = "./ec2-bastion-key-pair.pub"
}

variable "ec2-bastion-private-key-path" {
  description = "ec2-bastion-private-key-path"
  default     = "./ec2-bastion-key-pair.pem"
}

variable "ec2-bastion-ingress-ip-1" {
  description = "ec2-bastion-ingress-ip-1"
  default     = "0.0.0.0/0"
}

variable "bastion-bootstrap-script-path" {
  description = "bastion-bootstrap-script-path"
  default     = "../Scripts/bastion-bootstrap.sh"
}

variable "company_vpn_ips" {
  description = "company_vpn_ips"
  default     = ["0.0.0.0/0"]
}
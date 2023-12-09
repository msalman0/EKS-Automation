# Resource: aws_vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "main" {
  # The CIDR block for the VPC.
  cidr_block = var.vpc_cidr_block

  # Makes your instances shared on the host.
  instance_tenancy = "default"

  # Required for EKS. Enable/disable DNS support in the VPC.
  enable_dns_support = true

  # Required for EKS. Enable/disable DNS hostnames in the VPC.
  enable_dns_hostnames = true

  # Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC.
  assign_generated_ipv6_cidr_block = false

  # A map of tags to assign to the resource.
  tags = {
    Name = "main"
  }
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC id."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}
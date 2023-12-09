# Resource: aws_subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "public_1" {
  # The VPC ID.
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "192.168.101.0/24"

  # The AZ for the subnet.
  availability_zone = "eu-west-1b"

  # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource.
  tags = {
    Name                        = "public-eu-west-1a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "public_2" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "192.168.102.0/24"

  # The AZ for the subnet.
  availability_zone = "eu-west-1b"

  # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource.
  tags = {
    Name                        = "public-eu-west-1b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "public_3" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "192.168.103.0/24"

  # The AZ for the subnet.
  availability_zone = "eu-west-1c"

  # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource.
  tags = {
    Name                        = "public-eu-west-1c"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "private_1" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "192.168.11.0/24"

  # The AZ for the subnet.
  availability_zone = "eu-west-1a"

  # A map of tags to assign to the resource.
  tags = {
    Name                              = "private-eu-west-1a"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_2" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "192.168.12.0/24"

  # The AZ for the subnet.
  availability_zone = "eu-west-1b"

  # A map of tags to assign to the resource.
  tags = {
    Name                              = "private-eu-west-1b"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_3" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "192.168.13.0/24"

  # The AZ for the subnet.
  availability_zone = "eu-west-1c"

  # A map of tags to assign to the resource.
  tags = {
    Name                              = "private-eu-west-1c"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

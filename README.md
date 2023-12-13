# EKS-Automation

## Prerequistes 

####
To have AWS account
To have a development machine with terraform and  aws CLI installed and well configured
####

## Terraform

### Provider
Define your public cloud provider as aws
Define the user profile that would be used to interact with AWS CLI

### variables
Define all the variables that would be used in terrafom 
like project name , environment , VPC CIDR blocks , etc ..

### VPC 
starts creating AWS environment by creating an AWS VPC in your prefered region ex eu-west-1
VPC would have a CIDR block as 192.168.0.0/16
As this VPC will host EKS cluster we need to enable dns support and dns hostnames


As per Terrafom official documentation : 
enable_dns_support - (Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults to true.
enable_dns_hostnames - (Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.

### Subnets
VPC has three diffrent AZs as eu-west-1a , eu-west-1b and eu-west-1c
create one public zone and one private zone in each AZ

Public Subnets would have CIDR blocks
- 192.168.101.0/24
- 192.168.102.0/24
- 192.168.103.0/24

Private Subnets would have CIDR blocks
- 192.168.11.0/24
- 192.168.12.0/24
- 192.168.13.0/24

As long as these subnets will host EKS , then you need to add special tags as per 
[Amazon EKS VPC and subnet requirements and considerations](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)

```
  # A map of tags to assign to the resource.
  tags = {
    Name                        = "public-eu-west-1a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }

```

### Routing-table
It is just creating the routing table in this file without ssociation
Route table association will come in the next step
It create two different routes

- Public route : connects the subnet to internet gate-way
- private Route : connects the subnet to Nat gateway

### Routing-Table-Association
Here, the routes table created in the previous step start to be associated with different subnets so that
- Public subnets will be associated to public route
- Privatesubnets will ve associated to private route

### Internet-gateways
Provides a resource to create a VPC Internet Gateway. and link it to our VPC

```

resource "aws_internet_gateway" "main" {
  # The VPC ID to create in.
  vpc_id = aws_vpc.main.id

  # A map of tags to assign to the resource.
  tags = {
    Name = "main"
  }
}

```

### Elastic IPs
Provides an Elastic IP resource. 
EIP may require IGW to exist prior to association.

```
resource "aws_eip" "nat1" {
  # EIP may require IGW to exist prior to association. 
  # Use depends_on to set an explicit dependency on the IGW.
  depends_on = [aws_internet_gateway.main]
}

```
Three different EIPs were created to serve three different nat-gateways

### nat-gatways
Provides a resource to create a VPC NAT Gateway.
nat-gateways is located in the public subnet and it is used by private subnet to access the internet whenever needed

```
resource "aws_nat_gateway" "gw1" {
  # The Allocation ID of the Elastic IP address for the gateway.
  allocation_id = aws_eip.nat1.id

  # The Subnet ID of the subnet in which to place the gateway.
  subnet_id = aws_subnet.public_1.id

  # A map of tags to assign to the resource.
  tags = {
    Name = "NAT 1"
  }
}

```

### Bastion-host

Bastion host is nothing but an EC2 instance located in public subnet of VPC via which we will be able to access EKS cluster and apply kubectl commands

As this bastion would be the only jump station to manage EKS , then it should have a public IP and it should allow ssh access to it

As it is part of terraform automation , we will automatically generate its public key and secret key within the terraform files 

```
## Generate PEM (and OpenSSH) formatted private key.
resource "tls_private_key" "ec2-bastion-host-key-pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## Create the file for Public Key
resource "local_file" "ec2-bastion-host-public-key" {
  depends_on = [tls_private_key.ec2-bastion-host-key-pair]
  content    = tls_private_key.ec2-bastion-host-key-pair.public_key_openssh
  filename   = var.ec2-bastion-public-key-path
}

## Create the sensitive file for Private Key
resource "local_file" "ec2-bastion-host-private-key" {
  depends_on      = [tls_private_key.ec2-bastion-host-key-pair]
  content         = tls_private_key.ec2-bastion-host-key-pair.private_key_pem
  filename        = var.ec2-bastion-private-key-path
  file_permission = "0600"
}

```

Then as the key files are already located within terrafom directroy , we are going to make use of ec2 keys to automatically upload the k8s folder that contains yml files and rbac roles to be pushed to EKS cluster

```
  provisioner "file" {
    source      = "../K8s"
    destination = "/home/ec2-user/K8s"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ec2-bastion-private-key-path)
      host        = aws_instance.ec2-bastion-host.public_ip
    }
  }

```

As bastion host would be the management machine , we need to gurantee that, some basic tools are installed on it once the machine is up and running , that is why we push file of init scripts to userdata section

```
resource "aws_instance" "ec2-bastion-host" {
  ami                         = "ami-07355fe79b493752d"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2-bastion-host-key-pair.key_name
  vpc_security_group_ids      = [aws_security_group.ec2-bastion-sg.id, aws_security_group.allow_tls.id, aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true
  user_data                   = file(var.bastion-bootstrap-script-path)
  root_block_device {
    volume_size           = 8
    delete_on_termination = true
    volume_type           = "gp2"
    encrypted             = true
    tags = {
      Name = "${var.project}-ec2-bastion-host-root-volume-${var.environment}"
    }

  }

```

Why do we need a bastion host ?

-Administrative Access: A bastion host can provide a secure way to access and manage your EKS cluster's control plane or worker nodes. It allows you to establish SSH connections to the bastion host from your trusted network and then use that host to access the private resources within your VPC.

-Troubleshooting: In case you encounter any issues with your EKS cluster, having a bastion host in a public zone can help you troubleshoot and diagnose problems. You can use the bastion host to access logs, run diagnostic commands, or perform other troubleshooting tasks.

-Third-Party Tools: Some third-party tools or integrations may require access to your EKS cluster from a public network. In such cases, a bastion host can act as an intermediary to facilitate the connection between the public network and your private EKS cluster.


## K8s

## Scripts

## Helm

Why Private EKS 

Enhanced Security: Hosting your EKS cluster in private zones allows you to limit access to the Kubernetes API server endpoint, reducing the exposure to potential security threats from the public internet.

Controlled Access: With private zones, you have more control over who can access the EKS cluster. You can configure network policies, security groups, and IAM roles to restrict access to authorized entities within your VPC or connected network.

Integration with On-Premises DNS: Private zones enable you to integrate your EKS cluster with on-premises DNS systems, allowing for a unified DNS resolution across your infrastructure.

Compliance Requirements: Hosting EKS in private zones can help meet compliance requirements by ensuring that sensitive data and resources are not exposed to the public internet.


Why Bastion Host
Administrative Access: A bastion host can provide a secure way to access and manage your EKS cluster's control plane or worker nodes. It allows you to establish SSH connections to the bastion host from your trusted network and then use that host to access the private resources within your VPC.

Troubleshooting: In case you encounter any issues with your EKS cluster, having a bastion host in a public zone can help you troubleshoot and diagnose problems. You can use the bastion host to access logs, run diagnostic commands, or perform other troubleshooting tasks.

Third-Party Tools: Some third-party tools or integrations may require access to your EKS cluster from a public network. In such cases, a bastion host can act as an intermediary to facilitate the connection between the public network and your private EKS cluster.
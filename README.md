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
192.168.101.0/24
192.168.102.0/24
192.168.103.0/24

Private Subnets would have CIDR blocks
192.168.11.0/24
192.168.12.0/24
192.168.13.0/24

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
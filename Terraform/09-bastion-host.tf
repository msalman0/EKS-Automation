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

## AWS SSH Key Pair
resource "aws_key_pair" "ec2-bastion-host-key-pair" {
  depends_on = [local_file.ec2-bastion-host-public-key]
  key_name   = "${var.project}-ec2-bastion-host-key-pair-${var.environment}"
  public_key = tls_private_key.ec2-bastion-host-key-pair.public_key_openssh
  # public_key = file(var.ec2-bastion-public-key-path)
}

## EC2 Bastion Host Security Group
resource "aws_security_group" "ec2-bastion-sg" {
  description = "EC2 Bastion Host Security Group"
  name        = "${var.project}-ec2-bastion-sg-${var.environment}"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ec2-bastion-ingress-ip-1]
    description = "Open to Public Internet"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
    description      = "IPv6 route Open to Public Internet"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "IPv4 route Open to Public Internet"
  }

}

## EC2 Bastion Host Elastic IP
resource "aws_eip" "ec2-bastion-host-eip" {
  vpc = true
  tags = {
    Name = "${var.project}-ec2-bastion-host-eip-${var.environment}"
  }
}

## EC2 Bastion Host
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

  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "${var.project}-ec2-bastion-host-${var.environment}"
  }
  lifecycle {
    ignore_changes = [
      associate_public_ip_address,
    ]
  }
}

## EC2 Bastion Host Elastic IP Association
resource "aws_eip_association" "ec2-bastion-host-eip-association" {
  instance_id   = aws_instance.ec2-bastion-host.id
  allocation_id = aws_eip.ec2-bastion-host-eip.id
}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "sg-rule-ssh" {
  security_group_id = aws_security_group.bastion-sg.id
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = var.company_vpn_ips
  depends_on        = [aws_security_group.bastion-sg]
}

resource "aws_security_group_rule" "sg-rule-egress" {
  security_group_id = aws_security_group.bastion-sg.id
  type              = "egress"
  from_port         = 0
  protocol          = "all"
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  depends_on        = [aws_security_group.bastion-sg]
}
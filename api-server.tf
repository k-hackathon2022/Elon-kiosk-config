# Keypair
resource "aws_key_pair" "ec2_ssh_pub" {
  key_name   = "elon-kiosk-ssh-pubkey"
  public_key = file("./ec2-ssh.pub")
}

# AMI
data "aws_ami" "amazonLinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# SG
resource "aws_security_group" "sg_apiserver" {
  name        = "elon-kiosk-api-sg"
  description = "API Server Security Group"
  vpc_id      = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-api-sg"
  }
}

## SG Rules
### Ingress
resource "aws_security_group_rule" "sg_apiserver_rule_ing_http" {
  type                     = "ingress"
  from_port                = var.apiserver_port
  to_port                  = var.apiserver_port
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_alb.id
  security_group_id        = aws_security_group.sg_apiserver.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_apiserver_rule_ing_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_apiserver.id

  lifecycle {
    create_before_destroy = true
  }
}

### Egress
resource "aws_security_group_rule" "sg_apiserver_rule_eg_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_apiserver.id

  lifecycle {
    create_before_destroy = true
  }
}

# EC2
## AZ1
resource "aws_instance" "apiserver_az1" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.sg_apiserver.id
  ]

  subnet_id            = aws_subnet.priv_subnet_az1_api.id
  key_name             = "elon-kiosk-ssh-pubkey"
  iam_instance_profile = aws_iam_instance_profile.apiserver_az1_iam_profile.name

  tags = {
    Name = "elon-kiosk-api-az1"
    Tier = "api-server-layer"
  }
}

resource "aws_iam_instance_profile" "apiserver_az1_iam_profile" {
  name = "elon-kiosk-api-az1-iam-profile"
  role = aws_iam_role.ec2_role.name
}

## AZ2
resource "aws_instance" "apiserver_az2" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.sg_apiserver.id
  ]

  subnet_id            = aws_subnet.priv_subnet_az2_api.id
  key_name             = "elon-kiosk-ssh-pubkey"
  iam_instance_profile = aws_iam_instance_profile.apiserver_az2_iam_profile.name

  tags = {
    Name = "elon-kiosk-api-az2"
    Tier = "api-server-layer"
  }
}

resource "aws_iam_instance_profile" "apiserver_az2_iam_profile" {
  name = "elon-kiosk-api-az2-iam-profile"
  role = aws_iam_role.ec2_role.name
}

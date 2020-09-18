resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "r" {
  route_table_id            = aws_route_table.r.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
}

resource "aws_security_group" "security_main_vpc" {
  name        = "SG"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_main_vpc.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["193.48.143.174/32"]
  security_group_id = aws_security_group.security_main_vpc.id
}

resource "aws_security_group_rule" "out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_main_vpc.id
}

#Generate KeyPair
resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-one"
  public_key = tls_private_key.this.public_key_openssh
}


# Create a new instance of the latest Ubuntu 20.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"

resource "aws_instance" "web" {
  ami           = "ami-06fd8a495a537da8b"
  instance_type = "t2.micro"
  key_name = module.key_pair.this_key_pair_key_name
  #user_data contain in sh script
  user_data = file("install_apache.sh")

  tags = {
    Name = "HelloWorld"
  }
}
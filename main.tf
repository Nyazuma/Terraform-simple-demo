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

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "example" {

  #Allow Inbound HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow Inbound SSH 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow Outbound All
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  #Import PubKey
  public_key = file("terrapub.pem")
}


# Create a new instance of the latest Ubuntu 20.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"


resource "aws_instance" "web" {
  ami           = "ami-06fd8a495a537da8b"
  instance_type = "t2.micro"
  key_name = aws_key_pair.terraform-demo.key_name
  #user_data contain in sh script
  user_data = file("install_apache.sh")

  tags = {
    Name = "HelloWorld"
  }
}
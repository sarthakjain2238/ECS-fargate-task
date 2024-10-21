provider "aws" {
  region = "ap-south-1"  # Your preferred AWS region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-04a37924ffe27da53"  # Change to a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id

  tags = {
    Name = "MyEC2"
  }
}

resource "aws_eip" "my_eip" {
  instance = aws_instance.my_ec2.id
}

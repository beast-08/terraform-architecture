resource "aws_vpc" "interview" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "techie-interview"
  }
}
resource "aws_internet_gateway" "interview" {
  vpc_id = "${aws_vpc.interview.id}"
}
resource "aws_route_table" "interview" {
    vpc_id = "${aws_vpc.interview.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.interview.id}"
    }
    tags = {
        Name = "Route interview"
    }
}
resource "aws_subnet" "public" {
  vpc_id    = aws_vpc.interview.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-itw"
  }
}
resource "aws_subnet" "private" {
  vpc_id    = aws_vpc.interview.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-itw"
  }
}
resource "aws_route_table_association" "itw-assocation" {
  subnet_id     = aws_subnet.public.id
  route_table_id = aws_route_table.interview.id
}
resource "aws_security_group" "sg-itw" {
  name       = "sg_itw"
  description = "Allow itw inbound traffic"
  vpc_id     = aws_vpc.interview.id
  ingress {
    description     = "ITW from VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    description     = "ITW from VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    description     = "ITW from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg_igw"
  }
}
resource "aws_instance" "network-itw" {
  ami          = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  key_name = "master"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg-itw.id]
  associate_public_ip_address = true
   user_data                  = <<-EOF
                  #!/bin/bash
                  apt update -y
                  apt install -y apache2
                  systemctl start apache2
                  systemctl enable apache2
                  EOF
  tags = {
    Name = "network-itw"
  }
}
resource "aws_network_interface" "nwi-itw" {
  subnet_id  = aws_subnet.public.id
  private_ips = ["10.0.2.8"]
  security_groups = [aws_security_group.sg-itw.id]
  tags = {
    Name = "Nwi-itw"
  }
  }
  resource "aws_s3_bucket" "interview" {
  bucket = "interview-08"
}
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.interview.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-new" {
  name = "terraform-state-lock-new-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.interview.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}







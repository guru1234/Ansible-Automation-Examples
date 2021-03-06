# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
#resource "aws_vpc" "default" {
#  cidr_block = "10.0.0.0/16"
#}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "vpc-a41ddec0"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "rtb-3b5ffd5f"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
#resource "aws_subnet" "default" {
#  vpc_id                  = "${aws_vpc.default.id}"
#  cidr_block              = "10.0.1.0/24"
#  map_public_ip_on_launch = true
#}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = "vpc-a41ddec0"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "vpc-a41ddec0"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "terraform-example-elb"

  subnets         = ["subnet-82e00ff4","subnet-935269ca","subnet-cd975da9"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.test2a.id}","${aws_instance.test2b.id}","${aws_instance.test2c.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_instance" "test2a" {
  connection {
    user = "ubuntu"
  }
  lifecycle {
    create_before_destroy = true
  }
  instance_type = "t2.micro"

  ami = "${lookup(var.aws_amis, var.aws_region)}"

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "subnet-82e00ff4"
#  provisioner "remote-exec" {
 #   inline = [
 #     "sudo apt-get -y update",
 #     "sudo apt-get -y install nginx",
 #     "sudo service nginx start",
 #   ]
 # }
}
resource "aws_instance" "test2b" {
  connection {
    user = "ubuntu"
  }
  lifecycle {
    create_before_destroy = true
  }
  instance_type = "t2.micro"

  ami = "${lookup(var.aws_amis, var.aws_region)}"

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "subnet-935269ca"
#  provisioner "remote-exec" {
 #   inline = [
 #     "sudo apt-get -y update",
 #     "sudo apt-get -y install nginx",
 #     "sudo service nginx start",
 #   ]
 # }
}

resource "aws_instance" "test2c" {
  connection {
    user = "ubuntu"
  }
  lifecycle {
    create_before_destroy = true
  }
  instance_type = "t2.micro"

  ami = "${lookup(var.aws_amis, var.aws_region)}"

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "subnet-cd975da9"
#  provisioner "remote-exec" {
 #   inline = [
 #     "sudo apt-get -y update",
 #     "sudo apt-get -y install nginx",
 #     "sudo service nginx start",
 #   ]
 # }
}

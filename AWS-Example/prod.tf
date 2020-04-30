
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "sc13912-tf-course-20200430-2000"
  acl	 = "private"
  tags = {
    "Terraform" : "True"
  }
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
    tags = {
    "Terraform" : "True"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b" 
    tags = {
    "Terraform" : "True"
  }
}

resource "aws_default_security_group" "default"{
  vpc_id = aws_default_vpc.default.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "Allow standard ssh, http and https inbound and everything outbound"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }
  egress {
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "True"
  }
}

module "web_app" {
  source = "./modules/web_app"

  web_image_id          = var.web_image_id
  web_instance_type     = var.web_instance_type
  web_desired_capacity  = var.web_desired_capacity
  web_max_size          = var.web_max_size
  web_min_size          = var.web_min_size
  subnets               = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]
  security_groups       = [aws_security_group.prod_web.id,aws_default_security_group.default.id]
  web_app	 	= "prod"
  key_name		= var.key_name
}

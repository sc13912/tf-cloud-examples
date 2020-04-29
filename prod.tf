provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "sc13912-tf-course-202004"
  acl	 = "private"
}

resource "aws_default_vpc" "default" {}


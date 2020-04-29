provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_s3_bucket" "tf_course" {
  bucket = "sc13912-tf-course-20200429"
  acl	 = "private"
}

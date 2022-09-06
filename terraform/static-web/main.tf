terraform {
  #backend "s3" {
  #  bucket         = "kaokakelvin-nginx-static-web"
  #  key            = "terraform/static-web/terraform.tfstate"
  #  region         = "us-east-1"
  #  dynamodb_table = "terraform-state-locking-nginx-static-web"
  #  encrypt        = true
  #}
  # comment out backend section to create required resources first

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "kaokakelvin-nginx-static-web"
  force_destroy = true

  aws_s3_bucket_versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-sse" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking-nginx-static-web"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "static-web" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = var.instance_type
  key_name               = "nginx-keypair.pem"
  vpc_security_group_ids = ["sg-08ff285b264c49053", "sg-0dc6164b1fff25c7f"]

  tags = {
    Name  = var.name
    Group = var.group
  }
}
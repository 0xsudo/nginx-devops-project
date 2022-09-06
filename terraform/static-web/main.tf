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
  region = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "kaokakelvin-nginx-static-web"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
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

resource "aws_key_pair" "kp-nginx-deployer" {
  key_name   = "nginx-keypair.pem"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCu35XdCQPr7sRHVAFQC1+wnJtoK/WAJDIi0RdbcKCjSHxYAMSUQ85lwYeyosyt3F5m04hwfUTunsUtT1UlUXuggS+7J9/XwBIhFPY5KV1FGXInmt+eLOax9erPoXDpGIVoTXIXEX932lUnAhLHPSOp3Dok51WfzyLNScn3fjgzxWJne5sSDnEOOjO9cLOBRsqO2oKw04Z+jDYBK2EEal1sk+8ZiuSbRkgKkfyYg/+jD0p6tux+AVRzvh2nVg65ST4p2OUoj5brrO+g0+rv4ibRAbkPOURR/itaPc4NBuINIZiQAjyy07/lE+w/VmX5vaeHhewzfPBFZBs2Te8lrEO1uixn4uM2dXRyRFz/3V+GqE72+KRC+J8cB9GUGQ9YNgrNTKUwHEUSDR52KM+65qmWXNYhUu1ld0anq1QcRPoGtCu0DQFg2mtof6FV8PZXrNaSbEbnUMfpyT/MzUppoez24yZTSkqj7UcujwTcvE6Ad6rkhShZazoy1heY32xmEAx8QSDI9krldpKNGEP3zg0r4QLX28iM/udt03d3j1sIiovtOP5slsGSRWIzHP0q66cOZAsfKDEawuSv0RV3Vn94GgWfeKZTbY8QopmqXALylrw01lmFwNUIkV1YLIhHuc38YYrwiYP+XFIa48J4iZQ0FCBUV0aS4WS6W0EJnU42w== anon@anon"
}

resource "aws_instance" "static-web" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.kp-nginx-deployer.key_name
  vpc_security_group_ids = ["sg-08ff285b264c49053", "sg-0dc6164b1fff25c7f"]

  tags = {
    Name  = var.name
    Group = var.group
  }
}
terraform {
   backend "s3" {
     bucket         = "kaokakelvin-nginx"
     key            = "terraform/static-web/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "terraform-state-locking-nginx"
     encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    region = var.region
    profile = var.profile
}

resource "aws_instance" "static-web" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = "nginx-keypair.pem"
    vpc_security_group_ids = ["sg-08ff285b264c49053", "sg-0dc6164b1fff25c7f"]

    tags = {
        Name = var.name
        Group = var.group
    }
}
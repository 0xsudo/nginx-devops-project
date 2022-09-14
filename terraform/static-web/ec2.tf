resource "aws_key_pair" "devopsrole_nginx_deployer" {
  key_name   = "nginx-keypair.pem"
  public_key = file("~/.ssh/jenkins_rsa")
}

resource "aws_instance" "devopsrole_static_web" {
  ami                    = data.aws_ami.devopsrole_ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devopsrole_nginx_deployer.key_name
  vpc_security_group_ids = ["sg-0dc6164b1fff25c7f", aws_security_group.devopsrole_http_sg, aws_security_group.devopsrole_https_sg]
  subnet_id              = aws_subnet.devopsrole_public_subnet.id

  root_block_device {
    volume_size = 12
  }

  tags = {
    Name  = var.name
    Group = var.group
  }
}
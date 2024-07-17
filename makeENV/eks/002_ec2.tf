#########################################################################################################
## Create keypair for ec2
#########################################################################################################
resource "tls_private_key" "cwave-pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cwave-kp" {
  key_name   = "cwave-keypair"
  public_key = tls_private_key.cwave-pk.public_key_openssh
}

# Download key file in local
resource "local_file" "ssh-key" {
  filename        = "${var.pem_location}/cwave.pem"
  content         = tls_private_key.cwave-pk.private_key_pem
  file_permission = "0400"
}

# resource "local_file" "ssh-key-back" {
#   filename        = "cwave.pem"
#   content         = tls_private_key.cwave-pk.private_key_pem
#   file_permission = "0400"
# }

output "pem_location" {
  value = local_file.ssh-key.filename
}

#########################################################################################################
## Create ec2 instance for Bastion
#########################################################################################################
resource "aws_iam_instance_profile" "ec2_base_profile" {
  name = "ec2_cwave_profile_allow_ecr"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "bastion" {
  ami           = "ami-02422f4348cf351df"
  instance_type = "m7i.large"
  subnet_id     = aws_subnet.public-subnet-a.id

  iam_instance_profile = aws_iam_instance_profile.ec2_base_profile.name
  key_name             = aws_key_pair.cwave-kp.key_name
  vpc_security_group_ids = [
    aws_security_group.allow-ssh-sg.id,
    aws_security_group.public-sg.id
  ]

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  EOF
  tags = {
    Name = "bastion"
  }
}

# Check bastion public ip
output "bastion-public-ip" {
  value = aws_instance.bastion.public_ip
}

#########################################################################################################
## Create ec2 instance for docker
#########################################################################################################
#resource "aws_instance" "docker-playground" {
#  ami           = "ami-03ad6de565dcfd4b7"
#  instance_type = "m7g.large"
#  subnet_id     = aws_subnet.public-subnet-a.id
#
#  iam_instance_profile = aws_iam_instance_profile.ec2_base_profile.name
#  key_name             = aws_key_pair.wave-kp.key_name
#  vpc_security_group_ids = [
#    aws_security_group.allow-ssh-sg.id,
#    aws_security_group.public-sg.id
#  ]
#
#  user_data = <<-EOF
#  #!/bin/bash
#  sudo yum update -y
#  sudo yum install -y docker
#  sudo service docker start
#  sudo usermod -a -G docker ec2-user
#  EOF
#  tags = {
#    Name = "docker-playground"
#  }
#}
#
## Check docker-playground public ip
#output "docker-playground-public-ip" {
#  value = aws_instance.docker-playground.public_ip
#}
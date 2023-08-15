terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      Project = var.PROJECT_TAG
    }
  }
}

### Create Key-Pair ###
resource "aws_key_pair" "ci_project_key_pair" {
  key_name   = var.KEY_NAME
  public_key = file(var.PUBLIC_KEY_NAME)
  tags = {
    Name = var.KEY_NAME
  }
}

### Nexus SG ###
resource "aws_security_group" "jenkins_sg" {
  name        = var.JENKINS_SG_NAME
  description = "security group for Jenkins created by terraform"

  egress {
    description = "Allow All Outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Only SSH Access from any host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Access on Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.SG_NAME["Jenkins"]
  }
}

### Nexus SG ###
resource "aws_security_group" "nexus_sg" {
  name        = var.NEXUS_SG_NAME
  description = "security group for Nexus created by terraform"

  egress {
    description = "Allow All Outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Only SSH Access from any host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Access on Port 8081"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.SG_NAME["Nexus"]
  }
}

### Sonar SG ###
resource "aws_security_group" "sonar_sg" {
  name        = var.SONAR_SG_NAME
  description = "security group for Sonarqube created by terraform"

  egress {
    description = "Allow All Outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Only SSH Access from any host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Access on Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.SG_NAME["Sonar"]
  }
}

### Jenkins EC2 Instance ### 
resource "aws_instance" "jenkins_ec2_instance" {
  ami                    = var.AMIS["Jenkins"]
  instance_type          = var.INSTANCE_TYPE["Jenkins"]
  key_name               = aws_key_pair.ci_project_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = var.INSTANCE_NAME["Jenkins"]
  }
}

  provisioner "file" {
    source      = var.PROVISIONING_SCRIPT["Jenkins"]
    destination = "/tmp/${var.PROVISIONING_SCRIPT["Jenkins"]}"
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "chmod 0755 /tmp/${var.PROVISIONING_SCRIPT["Jenkins"]}",
      "sudo sh /tmp/${var.PROVISIONING_SCRIPT["Jenkins"]}"
    ]
    on_failure = fail
  }

  connection {
    user        = var.LOGIN_USER["Ubuntu"]
    private_key = file(var.PRIVATE_KEY_PATH)
    host        = self.public_ip
  }
}

### Nexus EC2 Instance ### 
resource "aws_instance" "Nexus_ec2_instance" {
  ami                    = var.AMIS["Nexus"]
  instance_type          = var.INSTANCE_TYPE["Nexus"]
  key_name               = aws_key_pair.ci_project_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.Nexus_sg.id]

  tags = {
    Name = var.INSTANCE_NAME["Nexus"]
  }
}

  provisioner "file" {
    source      = var.PROVISIONING_SCRIPT["Nexus"]
    destination = "/tmp/${var.PROVISIONING_SCRIPT["Nexus"]}"
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "chmod 0755 /tmp/${var.PROVISIONING_SCRIPT["Nexus"]}",
      "sudo sh /tmp/${var.PROVISIONING_SCRIPT["Nexus"]}"
    ]
    on_failure = fail
  }

  connection {
    user        = var.LOGIN_USER["CentOS"]
    private_key = file(var.PRIVATE_KEY_PATH)
    host        = self.public_ip
  }
}

### Sonar EC2 Instance ### 
resource "aws_instance" "Sonar_ec2_instance" {
  ami                    = var.AMIS["Sonar"]
  instance_type          = var.INSTANCE_TYPE["Sonar"]
  key_name               = aws_key_pair.ci_project_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.Sonar_sg.id]

  tags = {
    Name = var.INSTANCE_NAME["Sonar"]
  }
}

  provisioner "file" {
    source      = var.PROVISIONING_SCRIPT["Sonar"]
    destination = "/tmp/${var.PROVISIONING_SCRIPT["Sonar"]}"
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "chmod 0755 /tmp/${var.PROVISIONING_SCRIPT["Sonar"]}",
      "sudo sh /tmp/${var.PROVISIONING_SCRIPT["Sonar"]}"
    ]
    on_failure = fail
  }

  connection {
    user        = var.LOGIN_USER["Ubuntu"]
    private_key = file(var.PRIVATE_KEY_PATH)
    host        = self.public_ip
  }
}

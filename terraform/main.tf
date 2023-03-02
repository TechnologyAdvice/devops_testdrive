terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "Technology-Advice"

    workspaces {
      name = "DevOps-TerraformDrive"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.32.0"
    }
  }
}

# comment
locals {
  project = lower("example")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_iam_role" "example_role" {
  name               = local.project
  assume_role_policy = data.aws_iam_policy_document.example_assume_role.json

}

data "aws_iam_policy_document" "example_assume_role" {
  statement {
    sid = ""
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach SSM role.
resource "aws_iam_role_policy_attachment" "example_ssm_policy" {
  role       = aws_iam_role.example_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "example_profile" {
  name = local.project
  role = aws_iam_role.example_role.name
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.macro"

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${local.project}-root-volume"
    }
  }

  tags = {
    Name = "${local.project}"
  }

}
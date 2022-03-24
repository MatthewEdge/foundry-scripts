packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "linux2" {
  ami_name      = "foundry-ami"
  instance_type = "c5.xlarge"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  name    = "foundry-ami"
  sources = [
    "source.amazon-ebs.linux2"
  ]
  
  provisioner "shell" {
    environment_vars = [] #TODO: Add anything we want as a var here to dry this inline shell
    inline = [ #TODO: Explore maybe wrapping this in the script provisioner?
      "sudo yum update -y && sudo yum install -y openssl-devel",
      "curl --silent --location https://rpm.nodesource.com/setup_lts.x | sudo bash -",
      "sudo yum install -y nodejs"
    ]
  }
}
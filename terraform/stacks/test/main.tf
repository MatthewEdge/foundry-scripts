data "aws_ami" "linux2_ami" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["Amazon Linux 2 AMI"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

resource "random_id" "generate" {
  keepers = {
    # Generate a ec2 instance name each time we switch to a new ebs volume 
    ec2_instance_name = aws_instance.foundry_instance.id
  }

  byte_length = 8
}

resource "aws_ebs_volume" "foundry_instance" {
  availability_zone = "us-east-1a"
  size              = 35

  tags = {
    Name = "${var.tag}-EBS-Volume"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.foundry_instance.id
  skip_destroy = true
  tags = {
    Name = "${var.tag}-ebs-att" 
  }
}

resource "aws_instance" "foundry_instance" {
  ami               = data.aws_ami.linux2_ami
  availability_zone = "us-east-1"
  instance_type     = "c5-xlarge"

  tags = {
    Name = "${var.tag}-ec2-instance-${random_id.generate.ec2_instance_name}"
  }
}

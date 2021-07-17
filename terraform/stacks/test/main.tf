data "aws_ami" "linux2_ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_ebs_volume" "foundry_instance" {
  availability_zone = "us-east-1a"
  size              = 35

  tags = {
    Name = "${var.tag}-EBS-Volume"
    App  = var.tag
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/xvda"
  volume_id    = aws_ebs_volume.foundry_instance.id
  instance_id  = aws_instance.foundry_instance.id
  skip_destroy = true
}

resource "aws_instance" "foundry_instance" {
  ami               = data.aws_ami.linux2_ami.id
  availability_zone = "us-east-1"
  instance_type     = "c5-xlarge"

  tags = {
    Name = "${var.tag}-ec2-instance"
    App  = var.tag
  }
}

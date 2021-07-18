data "aws_ami" "linux2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "foundry_instance" {
  ami                    = data.aws_ami.linux2_ami.id
  availability_zone      = "${var.region}a"
  key_name               = "findthepath"
  instance_type          = "c5.xlarge"
  subnet_id              = "subnet-0627ae7cbbe84f6d9"
  vpc_security_group_ids = ["sg-069b1d42ccfb9a3d3"]

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
  }

  tags = {
    Name = "${var.tag}-ec2-instance"
    App  = var.tag
  }
}

output "instance_ip_addr" {
  value = aws_instance.foundry_instance.public_ip
}

output "instance_key_name" {
  value = aws_instance.foundry_instance.key_name
}

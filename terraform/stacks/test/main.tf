#TODO: Create single tag and merge app name

data "aws_ami" "linux2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "foundry_s3_role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      },
    ]
  })
}

resource "aws_iam_policy" "foundry_bucket_access" {
  name        = "foundry_bucket_policy"
  description = "Access to the FoundryVTT bucket"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : ["s3:ListBucket"],
        Resource : ["arn:aws:s3:::${var.bucket}"]
      },
      {
        Effect : "Allow",
        Action : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource : ["arn:aws:s3:::${var.bucket}/foundry/*"]
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "foundry_attach" {
  name       = "foundry_bucket_attachment"
  roles      = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = aws_iam_policy.foundry_bucket_access.arn
}

resource "aws_iam_instance_profile" "foundry_bucket_profile" {
  name = "foundry_bucket_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_instance" "foundry_instance" {
  ami                    = data.aws_ami.linux2_ami.id
  availability_zone      = "${var.region}a"
  key_name               = "findthepath"
  iam_instance_profile   = aws_iam_instance_profile.foundry_bucket_profile.name
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

  # user_data = "${file("install_foundry.sh")}"
}

resource "aws_route53_record" "foundry" {
  zone_id = var.r53_zone_id
  name    = "foundry.medgelabs.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.foundry_instance.public_ip]
}

resource "aws_lb" "front_end" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-069b1d42ccfb9a3d3"]
  subnets            = "subnet-0627ae7cbbe84f6d9"

  enable_deletion_protection = false

  tags = {
    Name = "${var.tag}-aws-lb"
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "tf-example-lb-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.selected.id
}

resource "aws_lb_target_group_attachment" "front_end" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.foundry_instance.id
  port             = 3000
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:822471943354:certificate/c636951d-3994-49a3-9752-42b0103cd3ca"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_listener_rule" "front_end" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }

  depends_on = [
    aws_lb_target_group.front_end
  ]
}

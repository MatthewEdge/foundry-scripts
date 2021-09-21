#TODO: Create single tag and merge app name

data "aws_ami" "linux2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
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

  alias {
    name                   = aws_lb.front_end.dns_name
    zone_id                = aws_lb.front_end.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb" "front_end" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-069b1d42ccfb9a3d3"]
  subnets            = ["subnet-0627ae7cbbe84f6d9", "subnet-0fa32319727709f09"]

  enable_deletion_protection = false

  tags = {
    Name = "${var.tag}-aws-lb"
  }
}

resource "aws_lb_target_group" "front_end" {
  name                 = "foundry-front-end-tg"
  port                 = 30000
  protocol             = "HTTP"
  vpc_id               = "vpc-057b3c8c30b29cf5e"
  deregistration_delay = 10

  health_check {
    matcher = "200-302"
  }
}

resource "aws_lb_target_group_attachment" "front_end" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.foundry_instance.id
  port             = 30000
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

  condition {
    host_header {
      values = ["foundry.medgelabs.io"]
    }
  }

  depends_on = [
    aws_lb_target_group.front_end
  ]
}

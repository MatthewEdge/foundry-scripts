data "aws_ami" "linux2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "foundry_s3_role"
  assume_role_policy = jsonencode({
     Version: "2012-10-17",
     Statement: [
       {
         Action: "sts:AssumeRole",
         Principal: {
           Service: "ec2.amazonaws.com"
         },
         Effect: "Allow",
         Sid: ""
       },
     ]
   })
}

resource "aws_iam_policy" "foundry_bucket_access" {
  name        = "foundry_bucket_policy"
  description = "Access to the FoundryVTT bucket"
  policy      = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: ["s3:ListBucket"],
        Resource: ["arn:aws:s3:::${var.bucket}"]
      },
      {
        Effect: "Allow",
        Action: [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource: ["arn:aws:s3:::${var.bucket}/foundry/*"]
       },
     ]
   })
}

resource "aws_iam_policy_attachment" "foundry_attach" {
  name       = "foundry_bucket_attachment"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = "${aws_iam_policy.foundry_bucket_access.arn}"
}

resource "aws_iam_instance_profile" "foundry_bucket_profile" {
  name  = "foundry_bucket_profile"
  role = "${aws_iam_role.ec2_s3_access_role.name}"
}

resource "aws_instance" "foundry_instance" {
  ami                    = data.aws_ami.linux2_ami.id
  availability_zone      = "${var.region}a"
  key_name               = "findthepath"
  iam_instance_profile = "${aws_iam_instance_profile.foundry_bucket_profile.name}"
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
  name = "foundry.medgelabs.io"
  type = "A"
  ttl = "300"
  records = [aws_instance.foundry_instance.public_ip]
}

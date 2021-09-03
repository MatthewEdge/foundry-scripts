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
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

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

// Start Lambda resource creation

# Cloudwatch event rule
resource "aws_cloudwatch_event_rule" "check-scheduler-event" {
  name                = "check-scheduler-event"
  description         = "check-scheduler-event"
  schedule_expression = var.schedule_expression
  depends_on          = [aws_lambda_function.scheduler_lambda]
  tags = {
    Name = "${var.tag}-cloudwatch-event-rule"
    App  = var.tag
  }
}

# Cloudwatch event target
resource "aws_cloudwatch_event_target" "check-scheduler-event-lambda-target" {
  target_id = "check-scheduler-event-lambda-target"
  rule      = aws_cloudwatch_event_rule.check-scheduler-event.name
  arn       = aws_lambda_function.scheduler_lambda.arn
}

# IAM Role for Lambda function
resource "aws_iam_role" "scheduler_lambda" {
  name               = "scheduler_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "${var.tag}-iam-role"
    App  = var.tag
  }
}

data "aws_iam_policy_document" "ec2-access-scheduler" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:CreateTags",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ec2-access-scheduler" {
  name   = "ec2-access-scheduler"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2-access-scheduler.json
}

resource "aws_iam_role_policy_attachment" "ec2-access-scheduler" {
  role       = aws_iam_role.scheduler_lambda.name
  policy_arn = aws_iam_policy.ec2-access-scheduler.arn
}

## create custom role

resource "aws_iam_policy" "scheduler_aws_lambda_basic_execution_role" {
  name        = "scheduler_aws_lambda_basic_execution_role"
  path        = "/"
  description = "AWSLambdaBasicExecutionRole"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "basic-exec-role" {
  role       = aws_iam_role.scheduler_lambda.name
  policy_arn = aws_iam_policy.scheduler_aws_lambda_basic_execution_role.arn
}

# AWS Lambda function
resource "aws_lambda_function" "scheduler_lambda" {
  filename         = "${path.module}/function.zip"
  function_name    = "foundry-shutdown-scheduler"
  role             = aws_iam_role.scheduler_lambda.arn
  handler          = "app"
  runtime          = "go:1.x"
  timeout          = 30
  memory_size      = 128
  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = [var.subnet_id]
  }
  tags = {
    Name = "${var.tag}-lambda-function"
    App  = var.tag
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_scheduler" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.check-scheduler-event.arn
}

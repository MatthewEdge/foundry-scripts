variable "tag" {
  default     = "FoundryVTT"
  description = "foundry tag name"
}

variable "region" {
  default = "us-east-1"
}

variable "r53_zone_id" {
  default = "Z1IKIK8GNXT5E9"
}

variable "bucket" {
  default = "medgelabs-foundry"
}

variable "schedule_expression" {
  default     = "cron(0 5 * * *)"
  description = "the aws cloudwatch event rule schedule expression that specifies when the scheduler runs. Default is 5 minuts past the hour. for debugging use 'rate(5 minutes)'. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
}

variable "security_group_ids" {
  type        = list(string)
  default     = ["sg-069b1d42ccfb9a3d3"]
  description = "list of the vpc security groups to run lambda scheduler in."
}

variable "subnet_id" {
  type        = string
  default     = "subnet-0627ae7cbbe84f6d9"
  description = "list of subnet_ids that the scheduler runs in."
}


#VPC Variables
variable "and_vpc" {
  description = "Default CIDR for Public"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "AWS Deployment Region"
  default = "eu-west-1"
}

#EC2 Variables
variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0f29c8402f8cce65c"
}


variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}




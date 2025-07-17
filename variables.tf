variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "project_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "terraform-demo"
}

variable "ubuntu_ami_pattern" {
  description = "Pattern to match Ubuntu AMI"
  type        = string
  default     = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}

variable "public_subnet_offset" {
  type    = number
  default = 1
}

variable "private_subnet_offset" {
  type    = number
  default = 10
}

variable "enable_availability_zone_num" {
  type    = number
  default = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ports" {
  type = map(number)
  default = {
    "ssh"  = 22
    "http" = 80
  }
}
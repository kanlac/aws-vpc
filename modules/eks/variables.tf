variable "region" {
  type        = string
  description = "AWS region"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}
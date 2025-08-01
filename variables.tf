variable "region" {
  type        = string
  description = "Region"
  default     = "ap-southeast-2" # Sydney
}

variable "zone_num" {
  type        = number
  description = "number of availability zones enabled"
  default     = 3
}
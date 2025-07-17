# aws-vpc

Create a production-grade multi-AZ VPC network environment on AWS with one click.

English | [简体中文](README_zh.md)

## Features

- Automatically create a VPC network across multiple Availability Zones (2 by default)
- Public subnet configuration included
- Automatic Internet Gateway configuration
- Pre-configured security groups supporting SSH and HTTP access
- Based on Ubuntu 24.04 LTS AMI
- Fully configurable network CIDR and subnet allocation

## Quick Start

1. Configure AWS credentials
2. Modify variables in `variables.tf` (optional)
3. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Main Variables

- `vpc_cidr_block`: VPC CIDR block (default: "10.0.0.0/16")
- `project_prefix`: Resource name prefix
- `enable_availability_zone_num`: Number of Availability Zones to enable
- `instance_type`: EC2 instance type

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

## Architecture Decisions

### NAT Gateway Configuration

The project deliberately deploys a single NAT Gateway in the first public subnet as a balanced approach between:

- **High Availability**: While multiple NAT Gateways (one per AZ) would provide the highest availability, a single NAT Gateway still serves all private subnets effectively.
- **Cost Optimization**: NAT Gateway pricing includes both hourly charges and data processing fees. Using a single NAT Gateway significantly reduces operational costs while maintaining adequate functionality for most use cases.

This design is suitable for non-critical workloads and development environments. For production environments with strict high-availability requirements, consider deploying additional NAT Gateways.

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

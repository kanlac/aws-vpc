# aws-vpc

[English](README.md) | 简体中文

> 本仓库演示如何使用 Terraform 搭建 VPC，并通过 module 部署 EKS 和 ElastiCache。

## 特性

- 自动创建跨多个可用区的 VPC 网络
- 包含公有子网配置
- 自动配置互联网网关（Internet Gateway）
- 预配置安全组，支持 SSH 和 HTTP 访问
- 基于 Ubuntu 24.04 LTS 镜像
- 完全可配置的网络 CIDR 和子网分配
- 部署高可用的 Redis 集群（使用 ElastiCache）
  - 部署在私有子网中以增强安全性
  - 支持跨可用区的多节点部署

## 架构图

> Mermaid 架构图请见 [README.md](README.md#architecture-graph)

## 架构决策

### NAT Gateway 配置

本项目在第一个公有子网中部署单个 NAT Gateway，这是在以下方面之间的平衡考虑：

- **高可用性**：虽然在每个可用区部署 NAT Gateway 可以提供最高的可用性，但单个 NAT Gateway 仍然可以有效地服务于所有私有子网。
- **成本优化**：NAT Gateway 的定价包括每小时费用和数据处理费用。使用单个 NAT Gateway 可以显著降低运营成本，同时仍然保持足够的功能性。

这种设计适用于非关键工作负载和开发环境。对于具有严格高可用性要求的生产环境，建议部署额外的 NAT Gateway。

## 快速开始

1. 配置 AWS 凭证
2. 修改 `variables.tf` 中的变量（可选）
3. 运行以下命令：

```bash
terraform init
terraform plan
terraform apply
```

## 主要变量

- `vpc_cidr_block`: VPC CIDR 块 (默认: "10.0.0.0/16")
- `project_prefix`: 资源名称前缀
- `enable_availability_zone_num`: 启用的可用区数量（同时决定 Redis 集群节点数）
- `instance_type`: EC2 实例类型
- `public_subnet_offset`: 公有子网的 CIDR 偏移量 (默认: 0，例如：10.0.0.0/24, 10.0.1.0/24)
- `private_subnet_offset`: 私有子网的 CIDR 偏移量 (默认: 10，例如：10.0.10.0/24, 10.0.11.0/24)

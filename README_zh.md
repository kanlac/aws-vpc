# aws-vpc

一键在 AWS 上创建生产级别的多可用区 VPC 网络环境。

[English](README.md) | 简体中文

## 特性

- 自动创建跨多个可用区（默认 2 个）的 VPC 网络
- 包含公有子网配置
- 自动配置互联网网关（Internet Gateway）
- 预配置安全组，支持 SSH 和 HTTP 访问
- 基于 Ubuntu 24.04 LTS 镜像
- 完全可配置的网络 CIDR 和子网分配

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
- `enable_availability_zone_num`: 启用的可用区数量
- `instance_type`: EC2 实例类型

# Secure AWS Network Infrastructure with Terraform

**AWS Cloud Security | Infrastructure as Code | Network Segmentation | VPC Flow Logs**

A hands-on AWS cloud security portfolio lab that uses Terraform to define a segmented Virtual Private Cloud (VPC), implement example network access controls, and configure VPC Flow Logs for network visibility.

> **Project scope:** This repository contains infrastructure code and a validation plan for a sandbox lab. It is **not a production deployment**. Deployment or testing results should be considered verified only when accompanied by actual execution evidence.

## Project objectives

- Design a VPC with separate public and private network tiers across two Availability Zones.
- Limit internet routing to public subnets; keep private subnets without a default internet route.
- Define example HTTPS-only security group rules and a subnet-level Network ACL (NACL).
- Configure VPC Flow Logs to send network flow metadata to Amazon CloudWatch Logs.
- Manage the environment declaratively with Terraform and document validation and cleanup steps.

## Architecture

![AWS secure network architecture](architecture/network-diagram.png)

| Component | Configuration |
| --- | --- |
| AWS Region | `us-east-1` (configurable) |
| VPC | `10.40.0.0/16` |
| Public subnet A | `10.40.10.0/24` |
| Public subnet B | `10.40.20.0/24` |
| Private subnet A | `10.40.110.0/24` |
| Private subnet B | `10.40.120.0/24` |
| Availability Zones | First two available AZs returned by AWS |
| Public routing | Internet Gateway with `0.0.0.0/0` in the public route table |
| Private routing | VPC-local route only; no NAT Gateway or internet default route |
| Logging | VPC Flow Logs (`ALL`) to CloudWatch Logs; 7-day retention by default |

**Note:** Public subnet auto-assignment of public IPv4 addresses is disabled. An Internet Gateway route does not, by itself, make a workload publicly accessible.

## Security controls implemented in the code

### Network segmentation

- Two public and two private subnets, with explicit route-table associations.
- An Internet Gateway and internet default route for public subnets only.
- No NAT Gateway and no default internet route for private subnets.

### Security groups

- **Example frontend security group:** allows inbound TCP `443` from the internet; outbound TCP `443` is limited to the VPC CIDR.
- **Example internal application security group:** allows inbound TCP `443` only from resources assigned the frontend security group; no outbound rules are defined.
- No inbound SSH (`22`) or RDP (`3389`) access is configured.

These security groups are **not attached to running workloads**; they demonstrate access-policy design.

### Network ACLs

A custom, stateless NACL is associated with **both public subnets**. Its rules allow inbound HTTPS and ephemeral TCP ports, and outbound TCP traffic. The private subnets use the VPC's default NACL.

The example custom NACL is TCP-focused and is **not a complete production firewall policy**. Real workloads may require additional protocol and return-path rules.

### Network monitoring

- VPC Flow Logs capture accepted and rejected flow metadata (`ALL`) and deliver to CloudWatch Logs.
- Terraform creates the CloudWatch Logs log group and IAM role/policy for log delivery.
- Flow Logs are not packet capture and do not show application payloads. Without network interfaces producing traffic, there may be no log events to inspect.

## Technologies

`AWS VPC` · `AWS IAM` · `Amazon CloudWatch Logs` · `VPC Flow Logs` · `Security Groups` · `Network ACLs` · `Terraform`

## Repository structure

```text
terraform-aws-secure-network/
├── README.md
├── .gitignore
├── architecture/
│   └── network-diagram.png
├── docs/
│   ├── security-decisions.md
│   ├── troubleshooting.md
│   └── validation.md
└── terraform/
    ├── flow_logs.tf
    ├── network.tf
    ├── outputs.tf
    ├── providers.tf
    ├── security.tf
    ├── terraform.tfvars.example
    ├── variables.tf
    └── versions.tf
```

## How to deploy in an authorized AWS sandbox

**Prerequisites:** Terraform `>= 1.5`, AWS CLI with authorized sandbox credentials, a region with at least two Availability Zones, and sufficient permissions for VPC, IAM, CloudWatch Logs, and flow logs.

From the repository root:

```bash
cd terraform
aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

To customize variables, copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` **before running** `terraform plan`:

- Windows PowerShell: `Copy-Item terraform.tfvars.example terraform.tfvars`
- macOS/Linux: `cp terraform.tfvars.example terraform.tfvars`

Review the Terraform plan before applying. AWS resources and CloudWatch logging can incur charges. Sandbox restrictions may prevent some resources from being created.

## How to validate

Follow the detailed [validation checklist](docs/validation.md). Key checks include:

1. Confirm the VPC and four subnet CIDR blocks, spread across two AZs.
2. Confirm the public route table has an Internet Gateway default route and the private route table does not.
3. Confirm the public NACL is attached to both public subnets.
4. Confirm security group rules allow the intended HTTPS paths and do not expose SSH.
5. Confirm the VPC Flow Logs destination, traffic type, and CloudWatch retention settings.
6. Record the observed results of `terraform plan` after deployment.

**Evidence status:** The repository includes a validation procedure; it does not claim that these checks have already passed. Add real, redacted screenshots or test output only after running the lab.

## Cleanup

From the **same Terraform working directory and state** used to create the resources:

```bash
terraform destroy
```

Confirm cleanup in the AWS Console. Even if an AWS training sandbox expires automatically, do not assume local state files or downloaded credentials are safe to publish.

## Design decisions and known limitations

This is a focused network security foundation, not a deployed application. It intentionally has **no EC2 instances, load balancer, application, NAT Gateway, CloudTrail trail, GuardDuty deployment, or CloudWatch alarms**. The sample security groups are unattached; therefore, this repository alone does not demonstrate end-to-end application connectivity or a live security incident investigation.

See [security decisions](docs/security-decisions.md) for trade-offs and [troubleshooting scenarios](docs/troubleshooting.md) for investigation exercises.

## Skills demonstrated by the project design

- Terraform infrastructure definition and AWS resource dependencies.
- VPC architecture, CIDR planning, public/private routing, and subnet isolation.
- Stateful security groups versus stateless NACLs.
- Centralized network flow metadata collection using CloudWatch Logs.
- Security documentation, validation planning, and infrastructure teardown.

**Portfolio context:** This is independent hands-on learning work, not claimed as employer production experience.

## Observed AWS sandbox deployment (October 18, 2026)

The screenshots in [`../evidence/`](../evidence/) show the following at capture time:

- [x] Terraform reported **28 added, 0 changed, 0 destroyed** after `terraform apply`.
- [x] VPC was **Available** with CIDR `10.40.0.0/16`.
- [x] Two public and two private subnets showed **Available** with the expected CIDR blocks.
- [x] Dedicated public and private route tables each showed two subnet associations.
- [x] The frontend and private-application security groups existed.
- [x] A custom NACL showed two subnet associations.
- [x] VPC Flow Logs was **Active** and targeted Amazon CloudWatch Logs.

**Not demonstrated by these images:** exact route entries, all NACL/security-group rule details, log-event ingestion, workload connectivity, traffic tests, or clean teardown. The screenshots are point-in-time evidence of a temporary lab, not a complete production security audit.

# Deployment / validation checklist

After `terraform apply`:

- [ ] `terraform output` prints VPC ID, 4 subnet IDs, and flow log ID.
- [ ] VPC console: CIDR is `10.40.0.0/16`.
- [ ] Subnets: 2 public, 2 private, distributed across 2 AZs, public IP assignment off.
- [ ] Route tables: public has `0.0.0.0/0 → igw-...`; private has no `0.0.0.0/0` route.
- [ ] NACL: custom NACL associated with *both* public subnets.
- [ ] Security groups: frontend inbound TCP 443 only; internal-app inbound TCP 443 from frontend SG ID only; neither allows SSH.
- [ ] VPC Flow Logs: `ALL`, active, CloudWatch destination configured.
- [ ] CloudWatch Logs: log group exists with specified retention. A log stream needs traffic and delivery time; absence immediately after deployment is not proof of failure.
- [ ] `terraform plan` after deployment shows no unexpected changes.
- [ ] Save redacted screenshots and a short summary of observed IDs / results.

## Useful CLI inspection (replace ID placeholders)

```bash
aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-xxxxxxxx
aws ec2 describe-flow-logs --filter Name=resource-id,Values=vpc-xxxxxxxx
aws ec2 describe-network-acls --filters Name=vpc-id,Values=vpc-xxxxxxxx
aws ec2 describe-security-groups --filters Name=vpc-id,Values=vpc-xxxxxxxx
```

## Evidence write-up template

**Goal:** __  **Design:** __  **Commands executed:** __  **Expected result:** __  **Observed result:** __  **Issue/fix:** __  **Screenshots:** __  **Cleanup confirmed:** __

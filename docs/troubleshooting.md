# Troubleshooting / interview scenarios

1. **Private subnet cannot reach the internet.** Expected by design. Check associated private route table: no default route or NAT. Describe how you would add least-privilege endpoints or controlled egress if required.
2. **SSH to an instance fails.** Expected: no instance, no SSH SG rule, no inbound SSH NACL rule. Prefer Systems Manager Session Manager for a future workload, with the necessary IAM/endpoint configuration.
3. **Flow Log group exists but there are no events.** No ENIs or workload traffic in this base lab. If you add workloads later, check traffic, log delivery IAM policy, CloudWatch permissions, and time allowed for delivery.
4. **HTTPS request times out.** No HTTPS server is deployed. Even with a server, inspect IGW/public address, routes, SG, stateless NACL return traffic and app listener.
5. **Terraform apply fails with AccessDenied.** Inspect error ARN/action, AWS identity, IAM rights, organization guardrails and region restrictions. Do not solve by granting broad admin access without approval.
6. **Resources differ from plan.** Run `terraform plan`; inspect drift and reconcile intentional changes in code; avoid manual console edits as the normal workflow.

# Security decisions and limitations

| Decision | Why | Limitation / next iteration |
|---|---|---|
| Separate public and private subnet tiers | Reduce exposure | No compute workload is deployed to prove app reachability |
| No NAT gateway or private default route | Prevent direct outbound public routing and avoid NAT cost | Private workloads would need approved VPC endpoints/NAT/proxy for dependencies |
| Disable auto public IPv4 assignment | Avoid accidental exposure | Public workloads need an explicit architecture for ingress |
| SG ingress only on 443 for example frontend; no SSH | Reduce management attack surface | SG is unattached, so this is policy evidence only |
| Restrict internal app SG inbound to frontend SG | SG-to-SG segmentation | Private app SG has no egress by default |
| Custom NACL on both public subnets | Demonstrate subnet stateless filter | TCP-oriented only; real workloads often need extra UDP/ICMP/ephemeral analysis |
| VPC Flow Logs to CloudWatch | Collect network metadata for investigations | Additional cost; no events until relevant traffic; not packet payloads |
| No EC2 / NAT / load balancer | Low-cost, focused architecture lab | Not a production reference architecture |

**Threat simulation idea:** Compare an overly permissive SSH rule against this design, then show its removal in a Terraform plan. Do not open port 22 to the internet in a real account just to make a screenshot.

# Example security groups for FUTURE workloads. No EC2, ALB, or application is deployed.
# Never expose SSH (22) or RDP (3389) to the internet in this lab.
resource "aws_security_group" "public_https" {
  name_prefix = "${var.project_name}-front-"
  description = "Example HTTPS frontend; no instances are attached"
  vpc_id      = aws_vpc.secure.id
  tags = { Name = "${var.project_name}-https-front" }
  lifecycle { create_before_destroy = true }
}
resource "aws_vpc_security_group_ingress_rule" "public_https" {
  security_group_id = aws_security_group.public_https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS frontend only"
}
resource "aws_vpc_security_group_egress_rule" "public_to_private_https" {
  security_group_id = aws_security_group.public_https.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Only HTTPS to VPC destinations"
}
resource "aws_security_group" "private_app" {
  name_prefix = "${var.project_name}-app-"
  description = "Example internal app SG restricted to frontend SG"
  vpc_id      = aws_vpc.secure.id
  tags = { Name = "${var.project_name}-private-app" }
  lifecycle { create_before_destroy = true }
}
resource "aws_vpc_security_group_ingress_rule" "app_from_frontend" {
  security_group_id            = aws_security_group.private_app.id
  referenced_security_group_id = aws_security_group.public_https.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Only frontend SG may reach internal HTTPS"
}
# Restrictive default: no private_app egress rules. Adjust only if future workloads require access.

# Custom *stateless* public subnet network ACL. Private subnets retain the VPC default NACL.
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.secure.id
  tags = { Name = "${var.project_name}-public-acl" }
}
resource "aws_network_acl_rule" "inbound_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}
resource "aws_network_acl_rule" "inbound_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
resource "aws_network_acl_rule" "outbound_tcp" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}
resource "aws_network_acl_association" "public" {
  count          = 2
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public[count.index].id
}
# These example NACL rules are TCP-only; extend for necessary UDP/ICMP before using with real workloads.

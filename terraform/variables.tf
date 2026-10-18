variable "aws_region" {
  description = "AWS region (must have at least two available AZs)."
  type        = string
  default     = "us-east-1"
}
variable "project_name" {
  description = "Short prefix for AWS resource names."
  type        = string
  default     = "secure-network-demo"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.project_name))
    error_message = "Use 3–31 lowercase letters, digits, and hyphens; start with a letter."
  }
}
variable "vpc_cidr" {
  type        = string
  description = "VPC IPv4 CIDR. Update subnet CIDRs if changing this."
  default     = "10.40.0.0/16"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Two non-overlapping public subnets inside the VPC."
  default     = ["10.40.10.0/24", "10.40.20.0/24"]
  validation {
    condition     = length(var.public_subnet_cidrs) == 2 && length(distinct(var.public_subnet_cidrs)) == 2
    error_message = "Supply two distinct public subnet CIDRs."
  }
}
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Two non-overlapping private subnets inside the VPC."
  default     = ["10.40.110.0/24", "10.40.120.0/24"]
  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && length(distinct(var.private_subnet_cidrs)) == 2
    error_message = "Supply two distinct private subnet CIDRs."
  }
}
variable "flow_log_retention_days" {
  type        = number
  description = "CloudWatch VPC flow log retention period."
  default     = 7
  validation {
    condition     = contains([1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1096,1827,2192,2557,2922,3288,3653], var.flow_log_retention_days)
    error_message = "Choose a valid CloudWatch Logs retention value."
  }
}

# Outputs

output "subnets_external_az1" {
  description = "ID of External subnets AZ1"
  value       = module.vpc.public_subnets[0]
}
output "subnets_external_az2" {
  description = "ID of External subnets AZ2"
  value       = module.vpc.public_subnets[1]
}
output "subnets_external_az3" {
  description = "ID of External subnets AZ3"
  value       = module.vpc.public_subnets[2]
}
output "subnets_internal_az1" {
  description = "ID of Internal subnets AZ1"
  value       = module.vpc.private_subnets[0]
}
output "subnets_internal_az2" {
  description = "ID of Internal subnets AZ2"
  value       = module.vpc.private_subnets[1]
}
output "subnets_internal_az3" {
  description = "ID of Internal subnets AZ3"
  value       = module.vpc.private_subnets[2]
}
output "subnets_management_az1" {
  description = "ID of Management subnets AZ1"
  value       = aws_subnet.mgmtAz1.id
}
output "subnets_management_az2" {
  description = "ID of Management subnets AZ2"
  value       = aws_subnet.mgmtAz2.id
}
output "subnets_management_az3" {
  description = "ID of Management subnets AZ3"
  value       = aws_subnet.mgmtAz3.id
}
output "security_group_external" {
  description = "ID of External security group"
  value       = aws_security_group.external.id
}
output "security_group_internal" {
  description = "ID of Internal security group"
  value       = aws_security_group.internal.id
}
output "security_group_mgmt" {
  description = "ID of Management security group"
  value       = aws_security_group.mgmt.id
}
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

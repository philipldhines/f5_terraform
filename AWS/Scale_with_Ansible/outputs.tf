# Outputs

output "bigipAZ1_mgmtIP_public" {
  description = "BIG-IP AZ1 management public IP address"
  value       = module.bigip["az1"].mgmtPublicIP
}
output "bigipAZ2_mgmtIP_public" {
  description = "BIG-IP AZ2 management public IP address"
  value       = module.bigip["az2"].mgmtPublicIP
}
output "bigipAZ3_mgmtIP_public" {
  description = "BIG-IP AZ3 management public IP address"
  value       = module.bigip["az3"].mgmtPublicIP
}

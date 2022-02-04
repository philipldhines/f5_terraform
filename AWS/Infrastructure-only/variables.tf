# Variables

variable "awsRegion" {
  description = "aws region"
  type        = string
  default     = "us-west-2"
}
variable "projectPrefix" {
  type        = string
  description = "prefix for resources"
  default     = "myDemo"
}
variable "resourceOwner" {
  type        = string
  description = "owner of the deployment, for tagging purposes"
  default     = "myName"
}
variable "awsAz1" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}
variable "awsAz2" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}
variable "awsAz3" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}

# Variables
variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone_public" {
  description = "Availability Zone for the subnet"
  default     = "eu-central-1a"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "my-cluster"
}

variable "region" {
  type = string
  description = "This is the AWS Region"
}

# Variable for vpc cidr
variable "vpc_cidr_block" {
  type = string
  description = "This is the VPC cidr Block for the EKS cluster"
}

variable "availability_zone_1" {
  type = string
  description = "This is availability zone 1 for the EKS cluster"
}

variable "availability_zone_2" {
  type = string
  description = "This is availability zone 2 for the EKS cluster"
}

# Variable for DNS hostnames
variable "vpc_dns_hostnames" {
  type = string
  description = "This is the variable for DNS hostnames"
}

# Create a variable for your vpc dns support
variable "vpc_dns_support" {
  type = string
  description = "This is the variable for DNS support"
}

variable "public_sub1_cidr_bock" {
  type = string
  description = "This is the cidr Block for public subnet1"
}

variable "public_sub2_cidr_bock" {
  type = string
  description = "This is the cidr Block for public subnet2"
}

variable "private_sub1_cidr_bock" {
  type = string
  description = "This is the cidr Block for private subnet1"
}

variable "private_sub2_cidr_bock" {
  type = string
  description = "This is the cidr Block for private subnet2"
}

variable "dest_cidr_bock" {
  type = string
  description = "This is the destination cidr Block"
}

variable "eks_version" {
  type = string
  description = "This is the version for the EKS cluster"
}

variable "cluster_name" {
  type = string
  description = "This is the name of the EKS cluster"
}

variable "cluster_desired_size" {
  type = number
  description = "This is the desired size of the EKS cluster"
  default = 2
}

variable "cluster_max_size" {
  type = number
  description = "This is the maximum size the EKS cluster"
  default = 6
}

variable "cluster_min_size" {
  type = number
  description = "This is the maximum size the EKS cluster"
  default = 2
}

variable "ami_type" {
  type = string
  description = "This is the AMI type of the EKS cluster"
}

variable "node_group_name" {
  type = string
  description = "This is the name of the Node group"
}

variable "instance_types" {
  type = list(string)
  description = "This is the list of instance types"
  default = ["t3.small", "t3.medium", "t3.large"]
}

variable "capacity_type" {
 type = string
 description = "This is the variable for your worker nodes capacity type"
}

variable "disk_size" {
    type = string
    description = "Disk size for your Worker Nodes"
    default = "50"
}

variable "max_unavailable" {
  type = string
  description = "max unavailable nodes for your worker nodes"
  default = 1
}
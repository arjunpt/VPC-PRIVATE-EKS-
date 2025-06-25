variable "vpc_name" {
    type = string
    description = "vpc name"
}
variable "aws_region" {
    type = string
    description = "region name"
}
variable "cidr_block" {
     type        = string
    description = "cidr block"
}
variable "igw_name" {
     type        = string
    description = "igw"
}
variable "env" {
     type        = string
    description = "environment where app deployed"
}


# PUBLIC SUBNET VARIABLES
variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
}

variable "public_cidr_block" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "public_availability_zone" {
  description = "List of availability zones for public subnets"
  type        = list(string)
}

variable "public_subnet_name" {
  description = "Base name for public subnets"
  type        = string
}

# PRIVATE SUBNET VARIABLES
variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
}

variable "private_cidr_block" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "private_availability_zone" {
  description = "List of availability zones for private subnets"
  type        = list(string)
}

variable "private_subnet_name" {
  description = "Base name for private subnets"
  type        = string
}
variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
}

variable "eip_name" {
  description = "Name tag for the Elastic IP"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway"
  type        = string
}

variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
}

variable "eks_sg" {
  description = "Name of the EKS security group"
  type        = string
}




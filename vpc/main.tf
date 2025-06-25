module "vpc" {
    source = "../modules/vpc"
    vpc_name = var.vpc_name
    cidr_block = var.cidr_block
    env = var.env
    igw_name = var.igw_name
    public_subnet_count = var.public_subnet_count
    public_cidr_block = var.public_cidr_block
    public_availability_zone = var.public_availability_zone
    public_subnet_name = var.public_subnet_name
    private_subnet_count = var.private_subnet_count
    private_cidr_block = var.private_cidr_block
    private_availability_zone = var.private_availability_zone
    private_subnet_name = var.private_subnet_name
    public_route_table_name = var.public_route_table_name
    private_route_table_name = var.private_route_table_name
    eip_name = var.eip_name
    nat_gateway_name = var.nat_gateway_name
    eks_sg = var.eks_sg

  
}

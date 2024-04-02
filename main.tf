module "eks-module" {
  source                 = "github.com/Mitchxxx/terraform-eks-modulejan24"
  region                 = "eu-west-2"
  vpc_cidr_block         = "10.0.0.0/16"
  vpc_dns_hostnames      = true
  vpc_dns_support        = true
  public_sub1_cidr_bock  = "10.0.10.0/24"
  public_sub2_cidr_bock  = "10.0.20.0/24"
  private_sub1_cidr_bock = "10.0.30.0/24"
  private_sub2_cidr_bock = "10.0.40.0/24"
  dest_cidr_bock         = "0.0.0.0/0"
  availability_zone_1    = "eu-west-2a"
  availability_zone_2    = "eu-west-2b"
  eks_version            = "1.28"
  ami_type               = "AL2_x86_64"
  cluster_name           = "ibt-k8s-cluster"
  capacity_type          = "ON_DEMAND"
  instance_types = ["m5.large", "m5.large", "m5.large"]
  node_group_name        = "eks_node"
}
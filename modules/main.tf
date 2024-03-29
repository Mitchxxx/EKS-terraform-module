resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_dns_hostnames
  enable_dns_support   = var.vpc_dns_support

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "vpc_igw"
  }

}

resource "aws_subnet" "eks_public_sub_one" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_sub1_cidr_bock
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "Eks_Public_Subnet_one"
  }
}

resource "aws_subnet" "eks_public_sub_two" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_sub2_cidr_bock
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "Eks_Public_Subnet_two"
  }
}

resource "aws_subnet" "eks_private_sub_one" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private_sub1_cidr_bock
  availability_zone = var.availability_zone_1

  tags = {
    Name = "Eks_Private_Subnet_one"
  }
}

resource "aws_subnet" "eks_private_sub_two" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private_sub2_cidr_bock
  availability_zone = var.availability_zone_2

  tags = {
    Name = "Eks_Private_Subnet_two"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "eks_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.eks_public_sub_one.id

  tags = {
    Name = "Natty_GW"
  }

  depends_on = [aws_internet_gateway.eks_igw]
}

resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "Private Subnet Route table"
  }
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "Public Subnet Route table"
  }
}

resource "aws_route" "public_subnet_nat_gw_route" {
  route_table_id         = aws_route_table.public_subnets_route_table.id
  destination_cidr_block = var.dest_cidr_bock
  gateway_id             = aws_internet_gateway.eks_igw.id
}

resource "aws_route" "private_subnet_nat_gw_route" {
  route_table_id         = aws_route_table.private_subnets_route_table.id
  destination_cidr_block = var.dest_cidr_bock
  nat_gateway_id         = aws_nat_gateway.eks_nat_gw.id
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.eks_public_sub_one.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route_table_association" "public_subnet_route_table_association_2" {
  subnet_id      = aws_subnet.eks_public_sub_two.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id      = aws_subnet.eks_private_sub_one.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

resource "aws_route_table_association" "private_subnet_route_table_association_2" {
  subnet_id      = aws_subnet.eks_private_sub_two.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

# Create an IAM role for the EKS cluster

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the necessary policies to the IAM role

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create an EKS cluster

resource "aws_eks_cluster" "mitchxxx_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = [aws_subnet.eks_private_sub_one.id, aws_subnet.eks_private_sub_two.id, aws_subnet.eks_public_sub_one.id, aws_subnet.eks_public_sub_two.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_role_attachment]
}


# Create an IAM role for the worker nodes

resource "aws_iam_role" "eks_worker_node_role" {
  name = "eks_worker_node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the necessary policies to the IAM role

resource "aws_iam_role_policy_attachment" "eks_worker_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ec2CR_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node_role.name
}

# Create the EKS node group

resource "aws_eks_node_group" "name" {
  cluster_name    = aws_eks_cluster.mitchxxx_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn

  # Subnet Configuration
  subnet_ids = [aws_subnet.eks_private_sub_one.id, aws_subnet.eks_private_sub_two.id]

  scaling_config {
    desired_size = var.cluster_desired_size
    min_size     = var.cluster_min_size
    max_size     = var.cluster_max_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  ami_type = var.ami_type

  # Configure the node group instances
  instance_types = var.instance_types

  capacity_type = var.capacity_type

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.

  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_ec2CR_policy_attachment
  ]
}

# Specify the tags for the node group
#  tag = {
#    Terraform = "true"
#    Environment = "prod"
#      }
# }
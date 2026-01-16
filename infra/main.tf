# Query available AZ's from AWS
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.6.0.0/16"

  azs             = local.azs
  private_subnets = ["10.6.1.0/24", "10.6.2.0/24", "10.6.3.0/24"]
  public_subnets  = ["10.6.101.0/24", "10.6.102.0/24", "10.6.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true  # cheaper (not full NAT HA)
  one_nat_gateway_per_az = false # set true if you want NAT HA

  enable_dns_hostnames = true
  enable_dns_support   = true

  # These tags are important so EKS can create LoadBalancers
  # Run ELB on 2 subnets only.
  public_subnet_tags_per_az = {
    "${local.azs[0]}" = { "kubernetes.io/role/elb" = "1" }
    "${local.azs[1]}" = { "kubernetes.io/role/elb" = "1" }
    "${local.azs[2]}" = { "kubernetes.io/role/elb" = "0" }
  }

  private_subnet_tags_per_az = {
    "${local.azs[0]}" = { "kubernetes.io/role/internal-elb" = "1" }
    "${local.azs[1]}" = { "kubernetes.io/role/internal-elb" = "1" }
    "${local.azs[2]}" = { "kubernetes.io/role/internal-elb" = "0" }
  }

  tags = {
    Project = var.cluster_name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Set Standard Support (14 months) instead of Extended Support (26 months)
  # Extended support has a hefty control plane fee.
  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }

  # Enable EKS Auto Mode with built-in node pools.
  bootstrap_self_managed_addons = false
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose", "system"]
    node_role_arn = aws_iam_role.node.arn
  }

  # Grant cluster admin access to cluster creator (whoever is executing terraform).
  enable_cluster_creator_admin_permissions = true
  tags = {
    Project = var.cluster_name
  }
}

resource "aws_iam_role" "cluster" {
  name = "eks-test-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachments_exclusive" "cluster" {
  role_name = aws_iam_role.cluster.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}

data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name = "eks-auto-node-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

# Query available AZ's from AWS
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(sort(data.aws_availability_zones.available.names), 0, 3)
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
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
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

  # EKS-managed add-ons (good default)
  cluster_addons = {
    coredns            = {}
    kube-proxy         = {}
    vpc-cni            = {}
    aws-ebs-csi-driver = {}
  }

  # Managed node group: 3 nodes across 3 AZ subnets
  eks_managed_node_groups = {
    main = {
      name = "main"

      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"

      min_size     = 3
      max_size     = 3
      desired_size = 3

      disk_size = 30

      # Optional: make node updates less disruptive
      update_config = {
        max_unavailable = 1
      }
    }
  }

  tags = {
    Project = var.cluster_name
  }
}

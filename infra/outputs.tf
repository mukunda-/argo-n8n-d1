output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_region" {
  value = var.region
}

output "aws_load_balancer_controller_irsa_role_arn" {
  value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
}
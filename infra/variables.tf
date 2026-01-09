variable "region" {
  type    = string
  default = "us-east-1"
}

# What to call the cluster. This is also attached as the "Project" tag for relevant
# resources.
variable "cluster_name" {
  type    = string
  default = "k8s-n8n"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "node_instance_type" {
  type    = string
  default = "t3a.medium"
  # For ARM/Graviton: t4g.medium
}

variable "local_test" {
  description = "Use LocalStack endpoints"
  type        = bool
  default     = false
}

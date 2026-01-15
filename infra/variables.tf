variable "region" {
  type    = string
  default = "us-east-1"
}

# What to call the cluster. This is also attached as the "Project" tag for relevant
# resources.
variable "cluster_name" {
  type    = string
  default = "n8n-cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
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

This is the entry to the EKS cluster. Route53 needs to be added manually to point to the NLB, and the NLB carries traffic to the traefik controller.

e.g.

Internet -> Route53 -> NLB (L4) -> K8s Nodes -> Traefik (L7) -> Services

This can't easily be done in at the terraform level because we're using automatic node pools. The automatic management is responsible for updating the internal target group for the NLB as nodes are added/removed.
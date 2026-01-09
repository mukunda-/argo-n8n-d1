#!/bin/bash

# Command listing to deploy the system to AWS.

# This uses the currently configured AWS profile.

cd infra

# Set up the K8s cluster.
terraform init
terraform apply

export CLUSTER_NAME=$(terraform output -raw cluster_name)
export AWS_LBC_ROLE_ARN=$(terraform output -raw aws_load_balancer_controller_irsa_role_arn)
export CLUSTER_REGION=$(terraform output -raw cluster_region)

# Configure kubectl with the current cluster.
eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME --region=$CLUSTER_REGION

# Generate passwords.
./gen-secrets.sh

# Deploy argocd to the cluster.
make install-argo

# Bootstrap: Deploy the load balancer controller. We can't deploy this with argocd because
# the argocd CLI can't install anything until the ingress is started.
envsubst < ./apps/aws/aws-load-balancer-controller/app.template.yaml | kubectl apply -f -

# Create load balancer
kubectl apply -f ./apps/aws/ingress/gateway.yaml
kubectl apply -f ./apps/aws/ingress/argocd.route.yaml

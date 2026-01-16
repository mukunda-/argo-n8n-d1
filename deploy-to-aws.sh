#!/bin/bash

# Command listing to deploy the system to AWS.

# This uses the currently configured AWS profile.

cd infra

# Set up the K8s cluster.
terraform init
terraform apply

export CLUSTER_NAME=$(terraform output -raw cluster_name)
#export AWS_LBC_ROLE_ARN=$(terraform output -raw aws_load_balancer_controller_irsa_role_arn)
export CLUSTER_REGION=$(terraform output -raw cluster_region)

read -p "Going to update kubeconfig with eks clusterGoing to update the kubeconfig for cluster $CLUSTER_NAME in region $CLUSTER_REGION"
read -p "Press Enter to continue..."

# Configure kubectl with the current cluster.
#eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME --region=$CLUSTER_REGION
aws eks --region $CLUSTER_REGION update-kubeconfig --name $CLUSTER_NAME

# Generate passwords.
./gen-secrets.sh

echo "Going to install argocd"
read -p "Press Enter to continue..."

# Deploy argocd to the cluster.
make install-argo

echo "Going to install argo root app"
read -p "Press Enter to continue..."

make create-argo-root-app-aws

# Bootstrap: Deploy the load balancer controller. We can't deploy this with argocd because
# the argocd CLI can't install anything until the ingress is started.
#envsubst < ./apps/aws/aws-load-balancer-controller/app.template.yaml | kubectl apply -f -

# Create load balancer
#kubectl apply -f ./apps/aws/ingress/gateway.yaml
#kubectl apply -f ./apps/aws/ingress/argocd.route.yaml

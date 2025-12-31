#!/bin/bash

n8n_db_password=$(openssl rand -hex 32)

if ! kubectl get namespace argocd &>/dev/null; then
    kubectl create namespace argocd || true
fi

if ! kubectl get namespace n8n &>/dev/null; then
    kubectl create namespace n8n || true
fi

echo Adding n8n-db-password to argocd namespace
kubectl create secret generic -n argocd n8n-db-password --from-literal=password=$n8n_db_password
echo Adding n8n-db-password to n8n namespace
kubectl create secret generic -n n8n n8n-db-password --from-literal=password=$n8n_db_password

redis_password=$(openssl rand -hex 32)

if ! kubectl get namespace redis &>/dev/null; then
    kubectl create namespace redis || true
fi

# Redis password is not used currently. This can be added later for security hardening,
# but otherwise is safe within the cluster if there are no misbehaving nodes.
echo Adding redis-password to redis namespace
kubectl create secret generic -n redis redis-password --from-literal=password=$redis_password
echo Adding redis-password to n8n namespace
kubectl create secret generic -n n8n redis-password --from-literal=password=$redis_password

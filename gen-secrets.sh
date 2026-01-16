#!/bin/bash

n8n_db_password=$(openssl rand -hex 32)
n8n_encryption_key=$(openssl rand -hex 32)

if ! kubectl get namespace cnpg &>/dev/null; then
    kubectl create namespace cnpg || true
fi

if ! kubectl get namespace n8n &>/dev/null; then
    kubectl create namespace n8n || true
fi

echo Adding n8n-db-password to cnpg namespace
kubectl create secret generic -n cnpg n8n-db-password \
    --type=kubernetes.io/basic-auth \
    --from-literal=username=n8n \
    --from-literal=password=$n8n_db_password
echo Adding n8n-db-password to n8n namespace
kubectl create secret generic -n n8n n8n-db-password \
    --type=kubernetes.io/basic-auth \
    --from-literal=username=n8n \
    --from-literal=password=$n8n_db_password
kubectl create secret generic -n n8n n8n-encryption-key \
    --from-literal=password=$n8n_encryption_key

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

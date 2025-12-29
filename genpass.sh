#!/bin/bash

pw=$(openssl rand -hex 32)

if ! kubectl get namespace argocd &>/dev/null; then
    kubectl create namespace argocd || true
fi

if ! kubectl get namespace n8n &>/dev/null; then
    kubectl create namespace n8n || true
fi

echo Adding n8n-db-password to argocd namespace
kubectl create secret generic -n argocd n8n-db-password --from-literal=password=$pw
echo Adding n8n-db-password to n8n namespace
kubectl create secret generic -n n8n n8n-db-password --from-literal=password=$pw

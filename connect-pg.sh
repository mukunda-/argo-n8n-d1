#!/bin/bash

# Open port and give a moment for it to open.
kubectl port-forward svc/cnpg-cluster-rw -n cnpg 8102:5432 &
sleep 2

PASS=$(kubectl get secret cnpg-cluster-superuser -n cnpg -o jsonpath='{.data.password}' | base64 -d)
psql "postgresql://postgres:$PASS@localhost:8102"

# End port forward
kill %1

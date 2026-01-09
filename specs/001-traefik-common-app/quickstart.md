# Quickstart: Traefik Common Application

**Feature**: 001-traefik-common-app  
**Deployment Time**: ~2 minutes  
**Prerequisites**: Kubernetes cluster with ArgoCD installed

## What You're Deploying

Traefik ingress controller as a common component providing:
- HTTP/HTTPS routing to services
- Kubernetes Gateway API support
- Dashboard for monitoring
- LoadBalancer for external access

## Quick Deploy (Existing Cluster)

If you already have ArgoCD running with the root application:

```bash
# Traefik deploys automatically via root-app directory recursion
# Verify deployment
kubectl get app traefik -n argocd
kubectl get pods -n traefik
kubectl get svc traefik -n traefik
```

That's it! The root application automatically discovers `apps/common/traefik/app.yaml`.

## Full Setup (New Environment)

### Local Development (Minikube)

```bash
# 1. Start Minikube
minikube start

# 2. Install ArgoCD
make install-argo

# 3. Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# 4. Deploy root application (includes Traefik)
kubectl apply -f root-app-local.yaml

# 5. Start Minikube tunnel (in separate terminal - required for LoadBalancer)
minikube tunnel

# 6. Verify Traefik
kubectl get pods -n traefik
kubectl get svc traefik -n traefik
```

### AWS Production

```bash
# 1. Deploy infrastructure
cd infra
terraform init
terraform apply

# 2. Configure kubectl
export CLUSTER_NAME=$(terraform output -raw cluster_name)
export CLUSTER_REGION=$(terraform output -raw cluster_region)
eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME --region=$CLUSTER_REGION

# 3. Install ArgoCD
make install-argo

# 4. Bootstrap and deploy apps
./deploy-to-aws.sh

# 5. Verify Traefik
kubectl get pods -n traefik
kubectl get svc traefik -n traefik  # Will show AWS ELB hostname
```

## Accessing the Dashboard

```bash
# Port-forward to dashboard
kubectl port-forward -n traefik svc/traefik 9000:9000

# Open browser to http://localhost:9000/dashboard/
```

## Testing Routing

Create a test service and IngressRoute:

```bash
# Deploy test app
kubectl create deployment echo --image=ealen/echo-server -n default
kubectl expose deployment echo --port=80 -n default

# Create IngressRoute
cat <<EOF | kubectl apply -f -
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: echo-route
  namespace: default
spec:
  entryPoints:
    - web
  routes:
    - match: Host(\`echo.localhost\`)
      kind: Rule
      services:
        - name: echo
          port: 80
EOF

# Test (on Minikube with tunnel running)
curl -H "Host: echo.localhost" http://localhost
```

## Testing Gateway API

```bash
# Create Gateway
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example-gateway
  namespace: default
spec:
  gatewayClassName: traefik
  listeners:
    - name: http
      protocol: HTTP
      port: 80
EOF

# Create HTTPRoute
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: echo-route
  namespace: default
spec:
  parentRefs:
    - name: example-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /echo
      backendRefs:
        - name: echo
          port: 80
EOF

# Test
curl http://localhost/echo
```

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl describe pod -n traefik -l app.kubernetes.io/name=traefik

# Check logs
kubectl logs -n traefik -l app.kubernetes.io/name=traefik
```

### No External IP (Minikube)

```bash
# Ensure minikube tunnel is running
minikube tunnel  # Run in separate terminal, requires sudo

# Verify service
kubectl get svc traefik -n traefik
```

### Routes Not Working

```bash
# Check dashboard for registered routes
kubectl port-forward -n traefik svc/traefik 9000:9000
# Visit http://localhost:9000/dashboard/ and check HTTP > Routers

# Check access logs
kubectl logs -n traefik -l app.kubernetes.io/name=traefik --tail=50
```

### ArgoCD Not Syncing

```bash
# Check app status
kubectl get app traefik -n argocd
argocd app get traefik

# Manual sync if needed
argocd app sync traefik

# Check for sync errors
argocd app get traefik --show-operation
```

## Verification Checklist

- [ ] Pod running in `traefik` namespace
- [ ] Service has EXTERNAL-IP (Minikube tunnel running locally, or AWS ELB in cloud)
- [ ] Dashboard accessible via port-forward on port 9000
- [ ] Test service routes correctly through Traefik
- [ ] Access logs visible in pod logs
- [ ] ArgoCD shows app as Healthy and Synced

## Resource Usage

Expected resource consumption:
- **CPU**: ~50-100m idle, up to 500m under load
- **Memory**: ~100-150Mi idle, up to 512Mi under load

Monitor with:
```bash
kubectl top pod -n traefik
```

## Next Steps

1. Configure TLS certificates (future feature - cert-manager integration)
2. Add middleware for authentication, rate limiting (per-service as needed)
3. Scale to multiple replicas for HA (when traffic demands)
4. Integrate with monitoring (Prometheus/Grafana)

## Constitutional Compliance

✅ **Declarative Infrastructure**: All config in Git via ArgoCD  
✅ **Multi-Environment Parity**: Same deployment works in Minikube and AWS  
✅ **Automated Synchronization**: Auto-sync enabled with prune and self-heal  
✅ **Dependency Ordering**: Sync wave 0 (foundational)  
✅ **Resource Management**: Limits declared in values.yaml

## References

- Feature specification: [spec.md](./spec.md)
- Implementation plan: [plan.md](./plan.md)
- Research decisions: [research.md](./research.md)
- Traefik docs: https://doc.traefik.io/traefik/

# Traefik Ingress Controller

Traefik is a modern HTTP reverse proxy and load balancer for microservices, deployed as a common component across all environments.

## Purpose

- **Ingress Controller**: Routes external traffic to Kubernetes services
- **API Gateway**: Provides routing, load balancing, and middleware capabilities
- **Dashboard**: Web UI for monitoring and configuration

## Configuration

The Traefik configuration is defined in `values.yaml` with production-ready defaults:

- **Gateway API**: Enabled for modern Kubernetes networking
- **LoadBalancer**: Service type for external access
- **Resource Limits**: CPU and memory constraints defined
- **Access Logs**: Enabled for observability and debugging

## Deployment

Traefik is deployed via ArgoCD at sync wave `0` as a foundational component. It must be ready before dependent applications that require ingress routing.

## Access

### Dashboard

Access the Traefik dashboard for monitoring:

```bash
# Port forward to dashboard
kubectl port-forward -n traefik $(kubectl get pods -n traefik -l app.kubernetes.io/name=traefik -o name) 9000:9000

# Access at http://localhost:9000/dashboard/
```

## Constitutional Compliance

This deployment follows the constitution principles:

- ✅ **Declarative Infrastructure**: ArgoCD Application manifest with Helm values
- ✅ **Automated Synchronization**: Auto-sync with prune and self-heal enabled
- ✅ **Dependency Ordering**: Sync wave 0 (foundational infrastructure)
- ✅ **Resource Management**: Requests and limits declared

## References

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Traefik Helm Chart](https://github.com/traefik/traefik-helm-chart)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)

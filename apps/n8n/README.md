# n8n Deployment with Argo CD

This directory contains the Argo CD Application manifest for deploying n8n using the 8gears Helm chart.

## Chart Information

- **Chart Repository**: https://8gears.container-registry.com/chartrepo/library
- **Chart Name**: n8n
- **Chart Version**: 0.23.0

## Deployment

### Apply the Application

```bash
kubectl apply -f apps/n8n/application.yaml
```

### Sync with Argo CD

```bash
# Using the Makefile
make argo-sync

# Or directly with argocd CLI
argocd app sync n8n
```

### Access n8n

#### Port Forward (Local Development)

```bash
kubectl port-forward -n n8n svc/n8n 5678:5678
```

Then access n8n at: http://localhost:5678

#### Using Ingress (Production)

Edit `application.yaml` or `values.yaml` to enable and configure ingress:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: n8n.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: n8n-tls
      hosts:
        - n8n.example.com
```

## Configuration

### Custom Values

Edit `values.yaml` to customize your n8n deployment. Common configurations include:

- **Database**: Switch from SQLite to PostgreSQL for production
- **Authentication**: Configure basic auth or OAuth
- **Webhook URL**: Set the external URL for webhooks
- **Resources**: Adjust CPU/memory limits based on your needs
- **Persistence**: Configure storage class and size

### Encryption Key

Generate and configure an encryption key for securing credentials:

```bash
openssl rand -base64 32
```

Add it to your values:

```yaml
secret:
  encryption_key: "your-generated-key"
```

### Environment Variables

Add custom environment variables in `values.yaml`:

```yaml
extraEnv:
  - name: N8N_BASIC_AUTH_ACTIVE
    value: "true"
  - name: N8N_BASIC_AUTH_USER
    value: "admin"
  - name: N8N_BASIC_AUTH_PASSWORD
    value: "changeme"
```

## Monitoring

Check the status of your n8n deployment:

```bash
# Application status
argocd app get n8n

# Pod status
kubectl get pods -n n8n

# Logs
kubectl logs -n n8n -l app.kubernetes.io/name=n8n -f
```

## Troubleshooting

### Application Not Syncing

```bash
# Force sync
argocd app sync n8n --force

# Check application events
argocd app get n8n --show-operation
```

### Pod Issues

```bash
# Describe the pod
kubectl describe pod -n n8n -l app.kubernetes.io/name=n8n

# Check events
kubectl get events -n n8n --sort-by='.lastTimestamp'
```

## References

- [n8n Documentation](https://docs.n8n.io/)
- [8gears n8n Helm Chart](https://github.com/8gears/n8n-helm-chart)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)

# Research: Traefik Common Application

**Feature**: 001-traefik-common-app  
**Date**: 2026-01-09  
**Status**: Complete

## Research Summary

This feature deploys Traefik using the official Helm chart with well-established patterns. No significant research required as all technical decisions are straightforward and align with existing project patterns.

## Technical Decisions

### Decision: Use Official Traefik Helm Chart
- **Rationale**: Official chart is maintained by Traefik Labs, receives regular updates, follows Kubernetes best practices
- **Alternatives considered**: 
  - Custom manifests: Rejected - reinventing the wheel, harder to maintain
  - Traefik Operator: Rejected - adds unnecessary complexity for our use case
- **Chart version**: 38.0.1 (current stable release)
- **Repository**: https://traefik.github.io/charts

### Decision: LoadBalancer Service Type
- **Rationale**: Provides external access across all environments - Minikube tunnel on local, AWS ELB on cloud
- **Alternatives considered**:
  - NodePort: Rejected - requires manual port management, not cloud-native
  - ClusterIP with port-forward only: Rejected - not suitable for production
- **Multi-environment support**: LoadBalancer abstraction adapts to environment (minikube tunnel vs AWS ELB)

### Decision: Kubernetes Gateway API
- **Rationale**: Future-proof networking standard, backwards compatible with Ingress, enables advanced routing
- **Alternatives considered**:
  - Ingress resources only: Rejected - older API, limited capabilities
  - Traefik IngressRoute CRDs only: Rejected - vendor lock-in
- **Approach**: Enable Gateway API provider alongside traditional Ingress support

### Decision: Single Replica (Not HA)
- **Rationale**: Sufficient for initial deployment, reduces resource usage, simpler operations
- **Alternatives considered**:
  - Multi-replica with leader election: Deferred - can add later when traffic demands it
- **Future consideration**: Scale to HA when traffic or SLA requirements justify

### Decision: Resource Limits
- **CPU**: 100m request, 500m limit - based on Traefik's lightweight nature
- **Memory**: 128Mi request, 512Mi limit - typical for ingress controllers handling moderate traffic
- **Rationale**: Prevents resource exhaustion, aligns with constitutional requirement for declared limits
- **Source**: Traefik documentation recommendations + experience from similar deployments

### Decision: Sync Wave 0
- **Rationale**: Foundational infrastructure must be ready before wave 2 applications (n8n, etc.) that may need ingress
- **Alternatives considered**:
  - Wave 1: Rejected - should be at same level as database operators (CNPG, Redis)
- **Dependencies**: None - Traefik depends only on Kubernetes API

## Best Practices Applied

### Traefik Configuration
- Access logs enabled for observability
- Dashboard enabled for debugging (port-forward access only, no external exposure)
- Namespace policy `from: All` allows cross-namespace routing (common in multi-tenant k8s)

### ArgoCD Configuration
- Automated sync with prune and self-heal per constitutional principle III
- CreateNamespace=true for convenience
- Label `managed-by: argocd` for tracking

### Documentation
- Readme includes access instructions, constitutional compliance checklist
- Follows existing pattern from redis, n8n, cnpg apps

## Open Questions

None - all technical requirements are clear and well-understood.

## References

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Traefik Helm Chart Values](https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
- Project constitution: `.specify/memory/constitution.md`

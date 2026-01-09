# Implementation Plan: Traefik Common Application

**Branch**: `001-traefik-common-app` | **Date**: 2026-01-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-traefik-common-app/spec.md`

## Summary

Deploy Traefik as a common ingress controller across all environments (local Minikube, AWS EKS) using GitOps principles. Traefik will be deployed via ArgoCD using the official Helm chart with configuration for LoadBalancer service type, Kubernetes Gateway API support, resource limits, dashboard access, and access logging. This provides a unified ingress solution replacing environment-specific implementations.

## Technical Context

**Language/Version**: YAML (Kubernetes manifests), Helm 3  
**Primary Dependencies**: Traefik Helm chart v38.0.1, ArgoCD, Kubernetes 1.25+  
**Storage**: N/A (stateless ingress controller)  
**Testing**: Manual verification - deployment health, LoadBalancer creation, routing validation, dashboard access  
**Target Platform**: Kubernetes (Minikube for local, EKS for AWS)  
**Project Type**: Infrastructure as Code (Kubernetes application deployment)  
**Performance Goals**: <60s deployment time, handle normal ingress traffic within resource limits  
**Constraints**: 100m-500m CPU, 128Mi-512Mi memory per pod, single replica (HA deployment out of scope)  
**Scale/Scope**: Single ingress controller serving all namespaces, ~10-50 routes initially

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ I. Declarative Infrastructure (NON-NEGOTIABLE)
- **Status**: PASS
- **Evidence**: ArgoCD Application manifest (`app.yaml`) declares infrastructure, Helm values file (`values.yaml`) defines configuration, all committed to Git
- **Compliance**: Terraform not applicable (Kubernetes workload, not cloud infrastructure), ArgoCD handles deployment with automated sync

### ✅ II. Multi-Environment Parity
- **Status**: PASS
- **Evidence**: Application placed in `apps/common/` directory, shared configuration works across Minikube and AWS environments
- **Compliance**: No environment-specific overrides required, LoadBalancer service type adapts per environment

### ✅ III. Automated Synchronization
- **Status**: PASS
- **Evidence**: `syncPolicy.automated.prune: true` and `syncPolicy.automated.selfHeal: true` configured in app.yaml
- **Compliance**: Automatic sync ensures Git remains source of truth, no manual kubectl intervention needed

### ✅ IV. Separation of Concerns
- **Status**: PASS
- **Evidence**: Traefik is a Kubernetes workload managed by ArgoCD, not cloud infrastructure managed by Terraform
- **Compliance**: Clear boundary - Terraform provisions EKS cluster, ArgoCD deploys Traefik within cluster

### ✅ V. Dependency Ordering and Readiness
- **Status**: PASS
- **Evidence**: Sync wave set to `"0"` (foundational infrastructure), deployed before wave 2 applications like n8n
- **Compliance**: Proper ordering ensures ingress controller ready before dependent applications need routing

### ✅ VI. Secrets Management
- **Status**: PASS
- **Evidence**: No secrets required for basic Traefik deployment, dashboard has no authentication (local access only via port-forward)
- **Compliance**: If TLS certificates added later, will use Kubernetes Secrets via cert-manager (not committed to Git)

### ✅ Technology Stack Standards
- **Status**: PASS
- **Evidence**: Helm chart version pinned (38.0.1), resource requests/limits declared, uses official Traefik chart
- **Compliance**: Follows project standards for version pinning and resource declarations

**GATE RESULT**: ✅ **PASS** - All constitutional requirements met, no violations to justify

## Project Structure

### Documentation (this feature)

```text
specs/001-traefik-common-app/
├── plan.md              # This file (implementation plan)
├── spec.md              # Feature specification (completed)
├── research.md          # Phase 0 output (N/A - no research needed)
├── data-model.md        # Phase 1 output (N/A - infrastructure deployment)
├── quickstart.md        # Phase 1 output (deployment guide)
└── contracts/           # Phase 1 output (N/A - no API contracts)
```

### Source Code (repository root)

```text
apps/common/traefik/
├── app.yaml           # ArgoCD Application manifest
├── values.yaml        # Traefik Helm chart values
└── readme.md          # Operational documentation

root-app-local.yaml    # Existing - already includes apps/common/*
```

**Structure Decision**: Infrastructure deployment following existing project pattern. All common applications are stored in `apps/common/` with subdirectories containing:
- `app.yaml`: ArgoCD Application definition
- `values.yaml`: Helm chart configuration
- `readme.md`: Documentation

The root application at `root-app-local.yaml` uses directory recursion with `include: '*/app.yaml'` to automatically discover and deploy all applications in `apps/common/`. No modifications to root-app needed - Traefik will be picked up automatically.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**No violations** - All constitutional requirements are met. This section intentionally left empty.

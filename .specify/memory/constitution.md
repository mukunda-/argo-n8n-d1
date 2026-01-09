<!--
SYNC IMPACT REPORT
==================
Version Change: NONE → 1.0.0
Type: INITIAL - First constitution generation from codebase analysis
Modified Principles: N/A (initial creation)
Added Sections: All sections created from template
Removed Sections: None

Templates Status:
✅ plan-template.md - Reviewed, aligns with GitOps and IaC principles
✅ spec-template.md - Reviewed, compatible with infrastructure feature specs
✅ tasks-template.md - Reviewed, supports infrastructure deployment workflows

Rationale: Initial constitution establishing governance for GitOps infrastructure project deploying n8n on Kubernetes.
Principles derived from: ArgoCD declarative deployment patterns, Terraform IaC practices, multi-environment support structure,
Helm chart management, and automated sync policies observed in codebase.

Follow-up TODOs: None - All placeholders resolved.
-->

# Argo N8N D1 Infrastructure Constitution

## Core Principles

### I. Declarative Infrastructure (NON-NEGOTIABLE)
All infrastructure and application deployments MUST be defined declaratively using Infrastructure-as-Code (IaC) and GitOps patterns. No manual `kubectl apply` or console changes are permitted in production environments.

**Rules**:
- Terraform for cloud infrastructure (VPC, EKS, IAM, networking)
- ArgoCD Application manifests for all Kubernetes deployments
- Helm charts with values files for application configuration
- All configuration changes MUST be committed to Git before deployment
- State drift detection and self-healing MUST be enabled via ArgoCD `syncPolicy.automated`

**Rationale**: Declarative definitions ensure reproducibility, auditability, disaster recovery capability, and prevent configuration drift. GitOps provides single source of truth with full change history.

### II. Multi-Environment Parity
Infrastructure MUST support multiple deployment targets (local development, staging, production) with minimal configuration differences. Environment-specific values MUST be isolated and clearly documented.

**Rules**:
- Common application definitions in `apps/common/` shared across environments
- Environment-specific overrides in `apps/{minikube,aws}/` directories
- Root application patterns per environment (e.g., `root-app-local.yaml`)
- Local development MUST be possible using Minikube without AWS dependencies
- No hardcoded environment values; use templating (envsubst, Helm values)

**Rationale**: Environment parity reduces deployment surprises, enables reliable testing in lower environments, and accelerates developer onboarding by supporting local workflows.

### III. Automated Synchronization
All ArgoCD applications MUST use automated sync policies with prune and self-heal enabled unless explicitly justified for critical production systems requiring manual approval.

**Rules**:
- Default `syncPolicy.automated.prune: true` to remove deleted resources
- Default `syncPolicy.automated.selfHeal: true` to revert manual changes
- Use sync waves (`argocd.argoproj.io/sync-wave`) for deployment ordering dependencies
- Label all ArgoCD apps with `managed-by: argocd` for tracking
- Manual sync approval requires written justification in app manifest comments

**Rationale**: Automation ensures Git remains the source of truth, prevents configuration drift, reduces operational toil, and enables rapid recovery from incidents.

### IV. Separation of Concerns
Infrastructure provisioning (Terraform) MUST be separated from application deployment (ArgoCD). Cloud resources and Kubernetes workloads are managed through distinct pipelines with clear boundaries.

**Rules**:
- Terraform manages: VPC, EKS cluster, IAM roles, networking, AWS-specific resources
- ArgoCD manages: Kubernetes workloads, operators, application configuration
- Output values from Terraform (e.g., IAM role ARNs) passed via environment substitution
- Infrastructure changes require `terraform plan` review before apply
- Application changes deploy automatically via ArgoCD sync

**Rationale**: Separation prevents accidental infrastructure destruction during application updates, enables independent scaling of cloud and workload management, and clarifies operational responsibilities.

### V. Dependency Ordering and Readiness
Application deployments MUST respect dependencies through sync waves and readiness checks. Dependent applications MUST NOT deploy until prerequisites are healthy.

**Rules**:
- Core infrastructure (CNPG operator, Redis) at wave 0-1
- Application workloads (n8n) at wave 2+
- Use `kubectl wait` for deployment readiness verification
- Database and stateful services MUST be ready before dependent apps sync
- Bootstrap scripts (deploy-to-aws.sh) MUST verify each step before proceeding

**Rationale**: Proper ordering prevents race conditions, failed deployments, and cascading errors. Explicit dependencies make deployment sequences transparent and debuggable.

### VI. Secrets Management
Secrets MUST be generated programmatically and stored securely. No secrets committed to Git. Environment-specific secrets managed separately per deployment target.

**Rules**:
- Use `gen-secrets.sh` or equivalent for password generation
- Kubernetes Secrets created via scripts, never in version control
- Database passwords stored as Kubernetes Secrets, referenced via `valueFrom.secretKeyRef`
- AWS credentials managed via IRSA (IAM Roles for Service Accounts)
- Local development secrets documented but not committed

**Rationale**: Prevents credential leakage, enables rotation without code changes, supports least-privilege access via IRSA, and maintains security compliance.

## Technology Stack Standards

**Infrastructure Layer**:
- Terraform >= 1.0 for AWS resource provisioning
- EKS (Kubernetes) as container orchestration platform
- ArgoCD for GitOps continuous delivery
- Helm 3 for application packaging

**Application Layer**:
- n8n as primary workflow automation platform
- CloudNativePG (CNPG) for PostgreSQL database management
- Redis for caching and queue management
- Custom community n8n image with extended modules

**Deployment Requirements**:
- All Helm charts MUST specify exact versions (not `latest`)
- Application images MUST use semantic versioning tags
- Terraform modules MUST pin versions using `~>` for minor updates
- Kubernetes manifests MUST declare resource limits and requests

## Development Workflow

### Local Development
1. Use Minikube for local Kubernetes cluster
2. Deploy via `make install-argo` and root-app-local.yaml
3. Port-forward services for local access (documented in Makefile targets)
4. Test changes locally before committing to Git

### Production Deployment
1. Infrastructure: `cd infra && terraform plan && terraform apply`
2. Configure kubectl: `eksctl utils write-kubeconfig`
3. Bootstrap ArgoCD: `make install-argo`
4. Deploy load balancer controller (one-time bootstrap, not in ArgoCD initially)
5. Apply root application: ArgoCD syncs all child applications automatically
6. Monitor ArgoCD UI for sync status and health

### Change Management
- Infrastructure changes: PR → Terraform plan review → Merge → Apply
- Application changes: PR → Merge → ArgoCD auto-sync
- Breaking changes require explicit migration plan documented in PR
- Rollbacks via Git revert (ArgoCD syncs previous state)

## Governance

This constitution defines the foundational engineering practices for the Argo N8N D1 infrastructure project. All infrastructure changes, application deployments, and operational procedures MUST comply with the principles established herein.

**Amendment Process**:
- Constitution changes require majority approval from project maintainers
- Proposed amendments MUST include impact analysis on existing infrastructure
- Version increments follow semantic versioning (MAJOR.MINOR.PATCH)
- Migration plans required for backward-incompatible changes

**Compliance Verification**:
- All PRs MUST reference relevant constitutional principles in description
- Violations of NON-NEGOTIABLE principles block merge
- Automated checks enforce: no secrets in Git, sync policies configured, versions pinned
- Periodic reviews ensure continued alignment with project goals

**Living Document**:
- Constitution reviewed quarterly for relevance
- Outdated principles updated or retired with proper versioning
- Lessons learned from incidents inform constitutional amendments

**Version**: 1.0.0 | **Ratified**: 2026-01-09 | **Last Amended**: 2026-01-09

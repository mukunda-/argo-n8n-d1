# Feature Specification: Traefik Common Application

**Feature Branch**: `001-traefik-common-app`  
**Created**: 2026-01-09  
**Status**: Draft  
**Input**: Add a Traefik app in the common apps directory for all deployments (separate from minikube-specific implementation)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deploy Traefik Ingress Controller (Priority: P1) 🎯 MVP

Platform operators need a common ingress controller that works across all deployment environments (local Minikube, AWS EKS, future cloud providers) to route external traffic to services. This replaces environment-specific ingress solutions with a unified approach.

**Why this priority**: Core infrastructure requirement blocking any service that needs external access. Without a common ingress controller, each environment needs custom configuration.

**Independent Test**: Deploy Traefik to a test cluster, verify LoadBalancer service is created, access the dashboard, confirm routing works for a test service.

**Acceptance Scenarios**:

1. **Given** a fresh Kubernetes cluster with ArgoCD, **When** the root-app syncs, **Then** Traefik is deployed to the `traefik` namespace with sync wave 0
2. **Given** Traefik is deployed, **When** checking the service, **Then** a LoadBalancer service is created with external endpoints
3. **Given** Traefik is running, **When** accessing the dashboard endpoint, **Then** the Traefik dashboard loads showing active routers and services
4. **Given** Traefik is operational, **When** creating an IngressRoute for a service, **Then** external traffic routes correctly to the backend service

---

### User Story 2 - Enable Gateway API Support (Priority: P2)

Platform operators need modern Kubernetes Gateway API support to use standardized routing configurations instead of proprietary Ingress resources. This enables advanced traffic management patterns and multi-cloud portability.

**Why this priority**: Gateway API is the future of Kubernetes networking, but current Ingress resources still work. This is a nice-to-have for forward compatibility.

**Independent Test**: Create a Gateway resource and HTTPRoute, verify Traefik configures routing correctly, test traffic flows through the gateway.

**Acceptance Scenarios**:

1. **Given** Traefik with Gateway API enabled, **When** applying a Gateway resource, **Then** Traefik creates the corresponding listeners
2. **Given** a Gateway exists, **When** creating an HTTPRoute, **Then** traffic routes according to the HTTPRoute rules
3. **Given** multiple namespaces, **When** creating HTTPRoutes in different namespaces, **Then** all routes work due to `namespacePolicy: from: All`

---

### User Story 3 - Monitor Traefik with Dashboard and Logs (Priority: P3)

Operations teams need visibility into ingress traffic patterns, routing rules, and errors to troubleshoot issues and monitor system health.

**Why this priority**: Observability is important but the system can function without it. Teams can still check pod logs directly if needed.

**Independent Test**: Port-forward to dashboard, verify routers/services display, check access logs in pod stdout, confirm entries appear for test traffic.

**Acceptance Scenarios**:

1. **Given** Traefik is deployed, **When** port-forwarding to port 9000, **Then** the dashboard displays at `/dashboard/`
2. **Given** access logs are enabled, **When** traffic flows through Traefik, **Then** access log entries appear in pod logs with request details
3. **Given** the dashboard is accessible, **When** viewing routers, **Then** all active IngressRoutes and HTTPRoutes are listed

---

### Edge Cases

- What happens when the LoadBalancer service type is not supported (e.g., bare metal without MetalLB)?
- How does the system handle misconfigured IngressRoutes that conflict?
- What if multiple Traefik instances are accidentally deployed?
- How are TLS certificates managed for HTTPS traffic?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST deploy Traefik as an ArgoCD Application in sync wave 0 (foundational infrastructure)
- **FR-002**: System MUST use the official Traefik Helm chart from `https://traefik.github.io/charts`
- **FR-003**: System MUST create a dedicated `traefik` namespace with ArgoCD auto-namespace creation
- **FR-004**: System MUST enable automated sync with prune and self-heal policies
- **FR-005**: System MUST configure Traefik as a LoadBalancer service type for external access
- **FR-006**: System MUST enable the Kubernetes Gateway API provider
- **FR-007**: System MUST configure gateway listeners with `namespacePolicy: from: All` to allow cross-namespace routing
- **FR-008**: System MUST declare resource requests (100m CPU, 128Mi memory) and limits (500m CPU, 512Mi memory)
- **FR-009**: System MUST enable the Traefik dashboard for monitoring and debugging
- **FR-010**: System MUST enable access logs for traffic observability
- **FR-011**: Deployment MUST be compatible with both local (Minikube) and cloud (AWS EKS) environments
- **FR-012**: Configuration MUST be stored in `apps/common/traefik/` directory following project structure conventions

### Key Entities *(include if feature involves data)*

- **Application Manifest** (`app.yaml`): ArgoCD Application resource defining deployment parameters
- **Helm Values** (`values.yaml`): Traefik configuration including providers, resources, and features
- **Documentation** (`readme.md`): Operational guide for deployment, access, and troubleshooting

### Non-Functional Requirements

- **NFR-001**: Traefik MUST start within 60 seconds of deployment
- **NFR-002**: Dashboard MUST be accessible via port-forward without authentication (local access only)
- **NFR-003**: Configuration changes via Git MUST sync automatically within 3 minutes
- **NFR-004**: Resource usage MUST stay within declared limits under normal load
- **NFR-005**: Documentation MUST include constitutional compliance verification

## Technical Constraints

- Use Traefik Helm chart version 38.0.1 (current stable)
- Follow GitOps declarative infrastructure principle
- Maintain parity with existing common app patterns (redis, n8n, cnpg)
- Support multi-environment deployment without code changes

## Success Criteria

1. Traefik deploys successfully via ArgoCD in both local and AWS environments
2. LoadBalancer service receives external IP/hostname
3. Dashboard accessible via port-forward
4. Test service routes correctly through Traefik
5. Access logs capture traffic details
6. Gateway API resources (Gateway, HTTPRoute) function correctly
7. Resource usage stays within limits
8. Documentation enables operators to deploy and troubleshoot independently

## Out of Scope

- TLS certificate management (future feature)
- Traefik middleware configuration (per-service concern)
- Multi-replica HA deployment (single replica sufficient for initial implementation)
- Custom error pages
- Rate limiting or authentication plugins
- Integration with external monitoring systems (Prometheus/Grafana)

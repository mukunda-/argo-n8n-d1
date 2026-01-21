# Makefile for Argo CD Project

.PHONY: fresh install-argo get-argo-password delete-argo-password argo-forward
.PHONY: install-argo-cli argo-cli-login argo-cli-login-core argo-sync
.PHONY: create-argo-apps-for-local create-argo-root-app connect-pg n8n-forward

fresh:
	./fresh.sh

# Install Argo
install-argo:
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Waiting for Argo CD to be ready..."
	kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
	@echo "Argo CD installed successfully!"
	@echo "Get the admin password with: make get-argo-password"
	@echo "Port forward with: make argo-forward"

# Retrieve the initial argo admin password. Argo recommends deleting this secret after the
# initial login.
get-argo-password:
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

delete-argo-password:
	kubectl -n argocd delete secret argocd-initial-admin-secret

# Port forward to Argo CD UI. This opens localhost:8101 to the Argo UI.
argo-forward:
	kubectl port-forward svc/argocd-server -n argocd 8101:443

# Install argocd CLI with brew
install-argo-cli:
	brew install argocd

# Log into the argo instance. Needs argo-forward first. This also uses --insecure,
# ignoring certificate validation.
argo-cli-login:
	argocd login localhost:8101 --username admin --password $(shell make get-argo-password) --insecure

# Log in via core. Does not need API server exposed and uses the current k8s context
# directly.
argo-cli-login-core:
	argocd login --core

argo-cli-admin-dashboard:
	argocd admin dashboard

# Sync all applications
argo-sync:
	argocd app sync -l managed-by=argocd

create-argo-apps-for-local:
	argocd app create root-app --file ./root-app-local.yaml

create-argo-root-app-aws:
	argocd app create root-app --file ./root-app-aws.yaml

connect-pg:
	./connect-pg.sh

# Open port to N8n instance.
n8n-forward:
	kubectl port-forward svc/n8n -n n8n 5678:80

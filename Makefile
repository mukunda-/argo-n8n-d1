# Makefile for Argo CD Project

.PHONY: install-argo argo-pass delete-argo-pass argo-forward 
.PHONY: argo-install-cli-brew argo-cli-login argo-sync
.PHONY: argo-create-cnpg argo-create-cnpg-cluster argo-create-n8n

# Install Argo
install-argo:
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Waiting for Argo CD to be ready..."
	kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
	@echo "Argo CD installed successfully!"
	@echo "Get the admin password with: make argo-pass
	@echo "Port forward with: make argo-forward

# Retrieve the initial argo admin password. Argo recommends deleting this secret after the
# initial login.
argo-pass:
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

delete-argo-pass:
	kubectl -n argocd delete secret argocd-initial-admin-secret

# Port forward to Argo CD UI. This opens localhost:8101 to the Argo UI.
argo-forward:
	kubectl port-forward svc/argocd-server -n argocd 8101:443

argo-install-cli-brew:
	brew install argocd

argo-cli-login:
	argocd login localhost:8101 --username admin --password $(shell make argo-pass)

# Sync all applications
argo-sync:
	argocd app sync -l managed-by=argocd

argo-create-cnpg:
	argocd app create cnpg --file ./apps/cnpg/app.yaml
argo-create-cnpg-cluster:
	argocd app create cnpg-cluster --file ./apps/cnpg-cluster/app.yaml

argo-create-n8n:
	argocd app create n8n --file ./apps/n8n/application.yaml

connect-pg:
	./connect-pg.sh

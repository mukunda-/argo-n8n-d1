# Makefile for Argo CD Project

.PHONY: install-argo argo-pass delete-argo-pass argo-forward argo-sync

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
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo "\nArgo recommends deleting this secret after the initial login. Run: make delete-argo-pass"

delete-argo-pass:
	kubectl -n argocd delete secret argocd-initial-admin-secret

# Port forward to Argo CD UI. This opens localhost:8080 to the Argo UI.
argo-forward:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

# Sync all applications
argo-sync:
	argocd app sync -l managed-by=argocd


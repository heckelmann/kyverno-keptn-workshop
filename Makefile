.DEFAULT_GOAL           := ready
GITHUB_REPOSITORY       ?= heckelmann/kyverno-keptn-workshop
CLUSTER_NAME            ?= workshop-cluster

.PHONY: create delete ready help

create: ## Create a Kind cluster
	@echo "Creating KinD cluster"
	@kind create cluster --name $(CLUSTER_NAME) --config cluster/kind.yaml
	@echo "Deploy ArgoCD"
	@kubectl create namespace argocd
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Wait for ArgoCD to be ready..."
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
	@echo "Configure ArgoCD"
	@kubectl apply -n argocd -f .devcontainer/argocd-nodeport.yaml
	@kubectl apply -n argocd -f .devcontainer/argocd-configmap.yaml
	@echo "Restart ArgoCD server..."
	@kubectl -n argocd rollout restart deploy/argocd-server
	@kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
	@helm upgrade --install --wait -n argocd app-of-apps ./charts/app-of-apps --set repo.name=$(GITHUB_REPOSITORY)
	@echo "ArgoCD Admin Password"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""
	@echo ""
	@echo "🎉 Installation Complete! 🎉"

delete: ## Delete Kind cluster
	@echo "Deleting KinD cluster"
	@kind delete cluster --name $(CLUSTER_NAME)
	@echo ""
	@echo ""
	@echo "🎉 Cluster Deleted! 🎉"

ready: ## Wait argocd is ready
ready: create
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
	@echo "ArgoCD Admin Password"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

help: ## Shows the available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

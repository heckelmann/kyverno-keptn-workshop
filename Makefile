.PHONY: help all create

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  all         to create a Kind cluster"
	@echo "  create      to create a Kind cluster"


all: create

create:
	@echo "Creating KinD cluster"
	@kind create cluster --config cluster/kind-devcontainer.yaml
	@echo "Deploy ArgoCD"
	@kubectl create namespace argocd
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Wait for ArgoCD to be ready..."
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
	@echo "Configure ArgoCD"
	@kubectl apply -n argocd -f .devcontainer/argocd-no-tls.yaml
	@kubectl apply -n argocd -f .devcontainer/argocd-nodeport.yaml
	@echo "Restart ArgoCD server..."
	@kubectl -n argocd rollout restart deploy/argocd-server
	@kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
	@echo "ArgoCD Admin Password"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""
	@echo ""
	@echo "🎉 Installation Complete! 🎉"

ready:
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
	@echo "ArgoCD Admin Password"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

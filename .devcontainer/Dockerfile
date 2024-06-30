FROM mcr.microsoft.com/vscode/devcontainers/base:0-ubuntu-22.04

# Install kubectl
RUN curl -sSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# Install Helm
RUN curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -

# Install k9s
RUN curl -sSL -o /tmp/k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_amd64.tar.gz \
    && tar -xzf /tmp/k9s.tar.gz -C /tmp \
    && mv /tmp/k9s /usr/local/bin/k9s \
    && chmod +x /usr/local/bin/k9s

# Install ArgoCD CLI
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

# Install Kyverno chainsaw
RUN curl -sSL -o /tmp/chainsaw.tar.gz https://github.com/kyverno/chainsaw/releases/latest/download/chainsaw_linux_amd64.tar.gz \
    && tar -xzf /tmp/chainsaw.tar.gz -C /tmp \
    && mv /tmp/chainsaw /usr/local/bin/chainsaw \
    && chmod +x /usr/local/bin/chainsaw

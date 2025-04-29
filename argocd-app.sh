#!/bin/bash
echo "Creating ArgoCD Application from GitHub"

argocd app create fastapi-helm-app \
  --repo https://github.com/soumya-sekhar-dey/kubernetes-helm-python-app.git \
  --path helm/fastapi-chart \
  --values helm/fastapi-chart/values.yaml \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated
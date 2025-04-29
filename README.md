# FastAPI Kubernetes Deployment with Helm and Argo CD

This project demonstrates how to deploy a FastAPI application to a Kubernetes cluster using Helm charts and GitOps via Argo CD. The code and Helm chart are stored in a GitHub repo, and Argo CD continuously syncs Kubernetes state from Git.

---

## 🚀 Project Structure

. ├── app/ # FastAPI source code ├── Dockerfile # Container definition ├── helm/ │ └── fastapi-chart/ # Helm chart │ ├── Chart.yaml │ ├── values.yaml │ └── templates/ │ ├── deployment.yaml │ └── service.yaml └── README.md


---

## ✅ Steps Followed

1. **FastAPI app built with `uvicorn`**
2. **Docker image built and pushed to Docker Hub**
3. **Helm chart created under `helm/fastapi-chart`**
4. **Kubernetes cluster created via Minikube**
5. **Helm chart successfully deployed locally**
6. **Argo CD installed in-cluster and UI exposed via port-forward**
7. **Argo CD app created to track the Helm chart from GitHub**

---

## ⚠️ Hiccups Faced

### 1. `ErrImagePull`
- Root cause: Docker image was only available locally, but Kubernetes couldn't pull it.
- Fix: Loaded image into Minikube via `minikube image load`.

### 2. App not accessible after deployment
- Root cause: FastAPI was binding to `127.0.0.1` instead of `0.0.0.0`.
- Fix: Updated `uvicorn` run command to use `host="0.0.0.0"`.

### 3. Helm chart deployed successfully, but no Kubernetes resources appeared
- Root cause: Misplaced `templates/` directory; Helm couldn't find templates.
- Fix: Moved `deployment.yaml` and `service.yaml` into correct `templates/` folder.

### 4. Argo CD unable to find `Chart.yaml`
- Root cause: macOS Git ignored filename case changes (`Chart.yaml` appeared as `chart.yaml` on GitHub).
- Fix: Renamed to a temp file and back to properly force Git to register the case-sensitive change.

### 5. Argo CD couldn't find `values.yaml`
- Root cause: Incorrect `--values` path during app creation.
- Fix: Used `--values values.yaml` (relative to chart root) instead of full path.

### 6. Argo CD showed synced, but Deployment wasn’t updated
- Root cause: Argo CD wasn’t applying changes in `values.yaml` because it wasn't told to track it.
- Fix: Recreated the app with `--values values.yaml` specified during `argocd app create`.

### 7. Argo CD didn't auto-sync after Git push
- Root cause: GitHub webhook not configured.
- Fix: Manually synced for now; will add webhook for push detection later.

---

## 🔧 Future Improvements

- Add GitHub webhook to enable auto-sync on `git push`
- Secure Argo CD with Ingress + TLS
- Add GitHub Actions to automate Docker builds and push updated image tags to Git

---

## 🛠️ Commands Reference

```bash
# Build and push Docker image
docker build -t <your-username>/fastapi-helm:latest .
docker push <your-username>/fastapi-helm:latest

# Deploy with Helm
helm install fastapi-helm-app helm/fastapi-chart

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port forward Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login to Argo CD
argocd login localhost:8080 --username admin --password <your-password> --insecure

# Create Argo CD app
argocd app create fastapi-helm-app \
  --repo https://github.com/<your-username>/kubernetes-helm-python-app.git \
  --path helm/fastapi-chart \
  --values values.yaml \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated


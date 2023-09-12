#!/bin/bash

minikube start --memory=8192 --cpus=3 --kubernetes-version=v1.27.5 --driver=docker -p gitops
minikube addons enable ingress -p gitops

# Set the working directory to always be argocd/bootstrap/
cd "$(dirname "${BASH_SOURCE[0]}")"

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd -n argocd argo/argo-cd -f values.yaml

# Create project
echo "Creating the main project..."
kubectl apply -f manifests/project.yaml

# Create the app of apps
echo "Creating the app of apps..."
kubectl apply -f manifests/application.yaml

kubectl port-forward service/argocd-server -n argocd 8080:443
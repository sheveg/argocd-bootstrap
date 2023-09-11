#!/bin/bash

minikube start --memory=8192 --cpus=3 --kubernetes-version=v1.27.5 --driver=docker -p gitops
minikube addons enable ingress -p gitops

#repo="https://github.com/sheveg/kafka-helm.git"

#read -p "Enter the Git API token with api scope permissions: " git_api_token
#read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Set the working directory to always be argocd/bootstrap/
cd "$(dirname "${BASH_SOURCE[0]}")"

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd -n argocd argo/argo-cd -f values.yaml

# Create a secret for the infrastructure repository
#echo "Configuring repository access..."
#kubectl create secret generic kafka-repo --namespace=argocd --type=Opaque --from-literal=url=$repository --from-literal=password=$git_api_token
#kubectl label secret -n argocd kafka-repo argocd.argoproj.io/secret-type=repository

# Create project
echo "Creating the main project..."
kubectl apply -f manifests/project.yaml

# Create the app of apps
echo "Creating the app of apps..."
kubectl apply -f manifests/application.yaml

kubectl port-forward service/argocd-server -n argocd 8080:443
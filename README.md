# AKS Demo - End-to-End CI/CD Setup

This repository contains a complete end-to-end CI/CD setup for deploying applications and infrastructure. It orchestrates the deployment of two microservices on top of an Azure Kubernetes Service (AKS) cluster with automated infrastructure provisioning, continuous integration, and continuous deployment.

## Overview

This project demonstrates a production-ready CI/CD pipeline that includes:
- **Infrastructure as Code (IaC)** using Terraform
- **Continuous Integration** for two microservices
- **Continuous Deployment** using ArgoCD
- **Monitoring and Observability** with Prometheus and Grafana

## Repository Structure

### Core Components

- **`terraform/`** - Infrastructure as Code
  - `tf_resources/` - Templatized base Terraform files for reusable infrastructure components
  - `project/` - Project-specific infrastructure requirements using microYAML approach
  
- **`src/`** - Application Source Code
  - `appA/` - Microservice A (Node.js)
  - `appB/` - Microservice B (.NET)

- **`kubernetes/`** - Kubernetes Manifests
  - `appA/` - Deployment, Service, Namespace, and Pod Disruption Budget configurations
  - `appB/` - Deployment, Service, Namespace, and Pod Disruption Budget configurations

- **`argocd-apps/`** - ArgoCD Applications
  - Application definitions for automated GitOps-based deployments

- **`helm-monitoring/`** - Monitoring Stack
  - Grafana and Prometheus Helm chart configurations

- **`aks_daily_report.sh`** - Daily reporting script that extracts Prometheus metrics and generates reports

## CI/CD Workflows

The repository includes 4 GitHub Actions workflows:

1. **Infrastructure Creation** - Provisions the AKS cluster and supporting Azure resources using Terraform
2. **Infrastructure Deletion** - Tears down all Azure resources
3. **App A CI Pipeline** - Builds, tests, and pushes App A Docker image; updates Kubernetes manifests
4. **App B CI Pipeline** - Builds, tests, and pushes App B Docker image; updates Kubernetes manifests

## Getting Started

### Prerequisites

- Azure Subscription
- GitHub Repository with Actions enabled
- `kubectl` configured

### Step 1: Configure GitHub Secrets and Variables

Before provisioning infrastructure, add the following as GitHub Secrets and Variables (refer to GitHub Actions documentation for setup):

**Required Secrets:**
- `AZURE_SUBSCRIPTION_ID` - Your Azure subscription ID
- `AZURE_CLIENT_ID` - Service Principal client ID
- `AZURE_TENANT_ID` - Azure tenant ID
- Federated credentials have been used for the Service Pricipal


### Step 2: Provision Infrastructure

1. Trigger the **Infrastructure Creation** workflow

### Step 3: Update ACR Credentials

After infrastructure provisioning:

1. Retrieve Azure Container Registry (ACR) credentials from the provisioned instance
2. Add them as GitHub Secrets:
   - `ACR_LOGIN_SERVER`
   - `ACR_USERNAME`
   - `ACR_PASSWORD`

### Step 4: Deploy Monitoring Stack

Refer to `helm-monitoring/installation.txt` for detailed setup instructions.

### Step 5: Setup ArgoCD

1. Create ArgoCD namespace and deploy:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. Apply ArgoCD applications for GitOps-based CD:
   ```bash
   kubectl apply -f argocd-apps/
   ```

This enables automatic synchronization of applications with the Git repository.

## Deployment Flow

1. **Infrastructure Setup** → Terraform provisions AKS cluster and dependencies
2. **Application Changes** → Push code to `appA` or `appB` → GitHub Actions CI pipeline triggers
3. **Build & Push** → Docker image built and pushed to ACR
4. **Manifest Update** → CI pipeline automatically updates Kubernetes manifests
5. **GitOps Sync** → ArgoCD detects manifest changes and deploys to cluster
6. **Monitoring** → Prometheus collects metrics, Grafana visualizes

## Monitoring and Reporting

- **Prometheus** - Collects metrics from the AKS cluster and applications
- **Grafana** - Provides visualization dashboards
- **Daily Reports** - Run `aks_daily_report.sh` to generate reports from Prometheus metrics

## Microservices

### App A (Node.js)
- Located in `src/appA/`
- Kubernetes manifests in `kubernetes/appA/`

### App B (.NET)
- Located in `src/appB/`
- Kubernetes manifests in `kubernetes/appB/`
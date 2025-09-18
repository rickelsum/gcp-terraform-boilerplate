This `README.md` file provides a high-level summary and step-by-step instructions for deploying the project.

-----

# GCP GKE Terraform Boilerplate for Nuxt.js

This project provides a complete Infrastructure as Code (IaC) and CI/CD solution to deploy a containerized Nuxt.js application on Google Kubernetes Engine (GKE). It's designed with separate `staging` and `production` environments.

The architecture uses **Terraform** to build the core infrastructure, **Docker** to containerize the application, **Google Artifact Registry** to store the container images, and **Google Cloud Build** to automate the build and deployment pipeline. For HTTPS, it leverages **Ingress-Nginx** and **Cert-Manager** to automatically provision and renew SSL certificates from Let's Encrypt.

-----

## 📋 Prerequisites

Before you begin, you'll need:

  * A **Google Cloud Platform (GCP) project** with billing enabled.
  * **Owner** or **Editor** permissions for your user account in the GCP project.
  * A registered **domain name**.
  * The `gcloud` command-line tool installed and authenticated, or access to the **Google Cloud Shell**.
  * **Git** installed.

-----

## 🚀 Deployment Steps

### Step 1: Initial Project Setup

First, you'll run a setup script that prepares your GCP project. This script is idempotent, meaning it's safe to run multiple times.

**What it does:**

  * Enables all necessary GCP APIs (GKE, Cloud Build, Artifact Registry, etc.).
  * Creates a single **GCS bucket** to securely store the Terraform state files for all environments.
  * Creates a **Google Artifact Registry** repository to store your Docker images.
  * Grants the Cloud Build service account the necessary permissions to deploy to GKE.

**Commands:**

```bash
# Clone your repository
git clone <your-repo-url>
cd <your-repo-name>

# Make the script executable and run it
chmod +x setup.sh
./setup.sh
```

After the script runs, **copy the GCS bucket name** it outputs. You'll need it in the next step.

-----

### Step 2: Deploy Infrastructure with Terraform

Next, you'll use Terraform to provision the GKE cluster and its networking.

**What it does:**

  * Creates a VPC network and subnetwork.
  * Provisions a cost-effective GKE Autopilot cluster for your chosen environment (`staging` or `production`).

**Commands (for staging):**

1.  **Configure Backend:** Open `environments/staging/backend.tf` and replace the placeholder with the GCS bucket name from Step 1. Do the same for `environments/production/backend.tf`.

2.  **Deploy:** Navigate to the staging environment directory and run Terraform.

    ```bash
    # Move into the staging directory
    cd environments/staging

    # Initialize Terraform to download plugins and configure the backend
    terraform init

    # Apply the configuration to create the infrastructure
    terraform apply -auto-approve
    ```

To deploy **production**, repeat the `terraform` commands from within the `environments/production` directory.

-----

### Step 3: One-Time Cluster Configuration for HTTPS

After the cluster is created, you need to install the necessary components to handle web traffic and SSL certificates. This only needs to be done once per cluster.

**What it does:**

  * Installs an **NGINX Ingress Controller** to manage external traffic routing to your application.
  * Installs **Cert-Manager**, which will automatically request, configure, and renew SSL certificates.
  * Configures a `ClusterIssuer` to tell Cert-Manager how to get certificates from Let's Encrypt.

**Commands:**

```bash
# Connect kubectl to your new staging cluster
gcloud container clusters get-credentials gke-cluster-staging --region <your-region>

# Apply the manifests for the Ingress controller and Cert-Manager
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml

# Wait a minute for the pods to start, then create the certificate issuer
# IMPORTANT: Replace the placeholder with your actual email address
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@your-domain.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

-----

### Step 4: Configure DNS

You now need to point your domain to the Ingress controller's load balancer.

**What it does:**

  * Creates an `A` record in your DNS provider that maps your domain (e.g., `staging.your-domain.com`) to the public IP address of the Kubernetes Ingress.

**Commands:**

1.  **Find the IP address:**
    ```bash
    kubectl get ingress -n ingress-nginx
    ```
2.  **Update DNS:** Go to your domain registrar or DNS provider and create an `A` record pointing your desired subdomain to the `EXTERNAL-IP` from the command above.

-----

### Step 5: Deploy the Nuxt.js Application

Finally, you'll trigger the CI/CD pipeline using Cloud Build to deploy your application.

**What it does:**

  * The Cloud Build pipeline automatically executes the steps in `cloudbuild.yaml`.
  * Builds your Nuxt.js application into a **Docker image**.
  * Pushes the new image to your **Artifact Registry**.
  * Updates the Kubernetes deployment manifest with the new image tag.
  * Applies the Kubernetes manifests (`deployment`, `service`, `ingress`) to your GKE cluster, rolling out the new version of your application.

**Commands:**

```bash
# From the root directory of your project

# Deploy to STAGING
gcloud builds submit --config cloudbuild.yaml \
  --substitutions=_CLUSTER_NAME='gke-cluster-staging',_DOMAIN='staging.your-domain.com'

# Deploy to PRODUCTION
gcloud builds submit --config cloudbuild.yaml \
  --substitutions=_CLUSTER_NAME='gke-cluster-production',_DOMAIN='app.your-domain.com'
```

After a few minutes, Cert-Manager will issue the certificate and your application will be live and secure at your specified domain\! 🎉
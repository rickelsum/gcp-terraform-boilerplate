#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Prompt for the project ID if not set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    read -p "Enter your GCP Project ID: " GOOGLE_CLOUD_PROJECT
fi

export PROJECT_ID=${GOOGLE_CLOUD_PROJECT}
export REGION="us-central1" # Change to your preferred region
export BUCKET_NAME="tf-state-bucket-${PROJECT_ID}"
export AR_REPO_NAME="nuxt-app-repo" # Artifact Registry repo name

# --- Set Project ---
echo "✅ Setting project to ${PROJECT_ID}..."
gcloud config set project ${PROJECT_ID}

# --- Enable APIs ---
echo "✅ Enabling necessary GCP APIs..."
gcloud services enable \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  cloudresourcemanager.googleapis.com

# --- Create GCS Bucket for Terraform State ---
echo "✅ Checking for GCS bucket: ${BUCKET_NAME}..."
if gsutil ls | grep -q "gs://${BUCKET_NAME}/"; then
    echo "Bucket already exists. Skipping creation."
else
    echo "Creating GCS bucket for Terraform state..."
    gsutil mb -p ${PROJECT_ID} -l ${REGION} gs://${BUCKET_NAME}
    gsutil versioning set on gs://${BUCKET_NAME}
    echo "Bucket created."
fi

# --- Create Artifact Registry Repository ---
echo "✅ Checking for Artifact Registry repository: ${AR_REPO_NAME}..."
if gcloud artifacts repositories describe ${AR_REPO_NAME} --location=${REGION} --project=${PROJECT_ID} > /dev/null 2>&1; then
    echo "Artifact Registry repository already exists. Skipping creation."
else
    echo "Creating Artifact Registry repository..."
    gcloud artifacts repositories create ${AR_REPO_NAME} \
        --repository-format=docker \
        --location=${REGION} \
        --description="Docker repository for Nuxt application"
    echo "Repository created."
fi

# --- Grant Cloud Build permissions to deploy to GKE ---
echo "✅ Granting Cloud Build the Kubernetes Engine Developer role..."
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/container.developer"

echo "🎉 Setup complete! You can now run Terraform."
#!/bin/bash

set -e

helpFunction()
{
   echo ""
   echo "Usage: $0 -o option"
   echo -e "\toption can be create, destroy, output"
   exit 1
}

while getopts "o:" opt
do
  case "$opt" in
    o ) option="$OPTARG" ;;
    ? ) helpFunction ;;
  esac
done

if [ "$option" != "create" ] && [ "$option" != "destroy" ] && [ "$option" != "output" ]
then
  echo "Parameter is incorrect";
  helpFunction
fi

if [ "$option" == "create" ]
then
  echo -e "\e[32mLoading Variables..."
  source ./email.txt
  source ./terraform.tfvars
  echo -e "\e[32mLogging in to GCP..."
  gcloud auth activate-service-account ${EMAIL} --key-file=credentials.json
  echo -e "\e[32mSetting default project..."
  gcloud config set project ${project}
  echo -e "\e[32mEnabling Google Kubernetes Service..."
  gcloud services enable container.googleapis.com
  echo -e "\e[32mCreating cluster..."
  terraform apply
  echo -e "\e[32mObtaining kubeconfig file..."
  gcloud config set compute/zone $(terraform output location)
  gcloud container clusters get-credentials $(terraform output cluster_name)
  echo -e "\e[32mAuthorizing local Docker client to connect to GCR..."
  gcloud auth configure-docker
  echo "Building Image..."
  docker build -t newbuild:latest app/
  docker tag newbuild:latest gcr.io/$(terraform output project)/pytest:v2
  echo "Pushing image to GCR Repository..."
  docker push gcr.io/$(terraform output project)/pytest:v2
  export IMAGE_URL='gcr.io/'"$project"'/pytest:v2'
  envsubst < manifests/deployment.yaml > manifests/deployment-subst.yaml
  echo "Deploying to GKS..."
  kubectl apply -f manifests/deployment-subst.yaml
  kubectl apply -f manifests/service.yaml
  kubectl apply -f manifests/ingress.yaml
  echo "Cleaning..."
  rm -f manifests/deployment-subst.yaml
  echo "Success!"
  exit 0
fi

if [ "$option" == "destroy" ]
then
  terraform destroy
  exit 0
fi

if [ "$option" == "output" ]
then
  terraform output
  exit 0
fi

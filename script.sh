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
echo "$option"

if [ "$option" == "create" ]
then
  source ./email.txt
  source ./terraform.tfvars
  gcloud auth activate-service-account ${EMAIL} --key-file=credentials.json
  gcloud config set project ${project}
  gcloud services enable container.googleapis.com
  terraform apply
  gcloud config set compute/zone $(terraform output location)
  gcloud container clusters get-credentials $(terraform output cluster_name)
  gcloud auth configure-docker
  docker build -t newbuild:latest app/
  docker tag newbuild:latest gcr.io/$(terraform output project)/pytest:v2
  docker push gcr.io/$(terraform output project)/pytest:v2
  export IMAGE_URL='gcr.io/'"$project"'/pytest:v2'
  envsubst < manifests/deployment.yaml > manifests/deployment-subst.yaml
  kubectl apply -f manifests/deployment-subst.yaml
  kubectl apply -f manifests/service.yaml
  kubectl apply -f manifests/ingress.yaml
  rm -f manifests/deployment-subst.yaml
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

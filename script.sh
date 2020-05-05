#terraform apply
source ./email.txt
source ./terraform.tfvars
gcloud auth activate-service-account ${EMAIL} --key-file=credentials.json
gcloud config set project ${project}
gcloud services enable container.googleapis.com
terraform apply
gcloud config set compute/zone $(terraform output location)
gcloud container clusters get-credentials $(terraform output cluster_name)
docker pull carlosrv999/test-python:latest
docker tag carlosrv999/test-python:latest gcr.io/$(terraform output project)/pytest:v2
docker push gcr.io/$(terraform output project)/pytest:v2
export IMAGE_URL='gcr.io/'"$project"'/pytest:v2'
envsubst < manifests/deployment.yaml > manifests/deployment-subst.yaml
kubectl apply -f manifests/deployment-subst.yaml
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/ingress.yaml
rm -f manifests/deployment-subst.yaml

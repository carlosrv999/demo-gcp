# New App

This app installs a sample deployment and service to GKS and exposes via ingress

## Prerequisites:

For running this sample, you need a Linux VM with the following installed

- GCP with a Service Account
- Docker >= 18.09
- Terraform >= 12
- Google SDK (gcloud command-line tool)
- kubectl https://kubernetes.io/es/docs/tasks/tools/install-kubectl/

No need to install third-party IngressController (like NGINX Ingress Controller or Istio) as GCP has its own.

## Installation

Download your Service Account credentials in JSON format and save to work directory of this repo, save file as **credentials.json**. The Service Account needs to have Project Owner permissions to the desired project.

Edit **email.txt** file with your service account email (example inside the file)

Edit **terraform.tfvars** with the desired region, project and zone. Be sure that the Service Account has Project Owner permissions to the project.

## Run the App

Run deploy.sh -o *option* where option can be either create, output or destroy.

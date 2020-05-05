provider "google" {
 credentials = file("credentials.json")
 project     = var.project
 region      = var.region
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = var.zone
  network  = "default"
  initial_node_count = 1

}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "location" {
  value = google_container_cluster.primary.location
}

output "project" {
  value = google_container_cluster.primary.project
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

data "google_compute_network" "my_vpc" {
  name    = "tech504-sam-vpc-2"
  project = var.project_id
}

data "google_compute_subnetwork" "public_subnet" {
  name    = "sam-vpc-2-public"
  region  = var.region
  project = var.project_id
}

data "google_compute_subnetwork" "private_subnet" {
  name    = "sam-vpc-2-private"
  region  = var.region
  project = var.project_id
}

resource "google_compute_instance" "app-vm" {
  name         = "tech504-sam-tf-app-vm"
  machine_type = "e2-small"
  zone         = "europe-west4-b"
  boot_disk {
    initialize_params {
      image = "projects/sparta-academy-455414/global/images/tech504-nathan-sparta-app-image"
      size = 10
      type = "pd-balanced"
    }
  }
  network_interface {
    access_config {
      network_tier = "STANDARD"
    }
    stack_type  = "IPV4_ONLY"
    subnetwork  = data.google_compute_subnetwork.public_subnet.self_link
  }
  metadata = {
    startup-script = "export DB_HOST=mongodb://10.0.3.2/posts\ncd nodejs20-sparta-test-app/app\nnpm install\npm2 start app.js"
  }
  tags = ["http-server"]

}

resource "google_compute_instance" "db-vm" {
  name         = "tech504-sam-tf-db-vm"
  machine_type = "e2-small"
  zone         = "europe-west4-b"
  boot_disk {
    initialize_params {
      image = "projects/sparta-academy-455414/global/images/tech504-nathan-mongo-db-vm-image"
      size = 10
      type = "pd-balanced"
    }
  }
  network_interface {
    network_ip = "10.0.3.2"
    stack_type  = "IPV4_ONLY"
    subnetwork  = data.google_compute_subnetwork.private_subnet.self_link
  }
  tags = ["db-server"]
}


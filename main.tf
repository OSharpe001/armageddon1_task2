terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  project     = "elemental-apex-420520"
  credentials = "elemental-apex-420520-8d3f13306920.json"
  region      = "us-east1"
  zone        = "us-east1-d"
}

resource "google_compute_network" "task2-vpc-network" {
  name                    = "task2-vpc-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "task2-allow-http" {
  name    = "task2-allow-http"
  network = google_compute_network.task2-vpc-network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# SETTING UP THE VM
resource "google_compute_instance" "task2-compute-instance" {
  name         = "task2-compute-instance"
  machine_type = "n1-standard-1"
  zone         = "us-east1-d"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # OUR NETWORK INTERFACE IS OUR VPC (<VPCNAME1>.<VPCNAME2>.name)
  network_interface {
    network = google_compute_network.task2-vpc-network.name

    access_config {
      // Ephemeral IP
    }
  }

  tags = ["http-server", "https-server"]

  # metadata_startup_script = file("${path.module}/runScript.sh")
  # metadata_startup_script = "${file("/runScript.sh")}" #ANOTHER WAY TO RUN ANOTHER FILE FROM THE SAME FOLDER
  metadata_startup_script = "#! /bin/bash sudo apt-get update sudo apt-get install apache2 -y sudo systemctl start apache2 sudo systemctl enable apache2 echo '<h1>Deployed via Terraform</h1>' | sudo tee /var/www/html/index.html"
}

# PUBLIC IP ADDRESS OF THE VPC
output "public_ip" {
  value = google_compute_instance.task2-compute-instance.network_interface[0].access_config[0].nat_ip
}

# VPC ID
output "vpc-id" {
  value = google_compute_network.task2-vpc-network.id
}

# VM NAME
# output "vpc" {
#   value = google_compute_instance.task2-compute-instance.network_interface[0].network
# }

# SUBNET OF THE VM INSTANCE
output "subnet" {
  value = google_compute_instance.task2-compute-instance.network_interface[0].subnetwork
}

# INTERNAL IP ADDRESS OF THE VM INSTANCE
output "internal_ip" {
  value = google_compute_instance.task2-compute-instance.network_interface[0].network_ip
}

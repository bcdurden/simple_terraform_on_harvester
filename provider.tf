terraform {
  required_version = ">= 0.13"
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.3"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
  backend "kubernetes" {
    secret_suffix    = "state-rke2"
    config_path      = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = var.local_kubeconfig
}
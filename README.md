# Simple Terraform on Harvester
This repo is meant to be a simple snapshot of using Terraform to provision RKE2 clusters directly onto Harvester using the Harvester Terraform provider.

## Dependencies
* Harvester cluster up and running
* kubeconfig from harvester cluster set to current context
* Terraform
* VM image uploaded to Harvester for use (any common cloud image will do, Ubuntu 22.04 recommended)
* VM Network defined (see notes below for how to do this simply)

## TL;DR

This repo is meant to be explored and tested in a PoC environment. So if you just want to start going fast, then have at it.

Edit the `example.tfvars` file and set everything to your liking. Bear in mind there are some defaults set in the various `variables.tf` files within the repo, so not all possible values will be exposed to you. Feel free to edit, hack, delete, or whatever you like to make it work for you or gel with your existing workloads.

Ensure the static IP assignments in `cp_network_data` match your network and ensure the `IPPool` and `LoadBalancer` objects also match (including selector names vs your prefix). There's likely a better way to do this but Terraform does not handle CRDs very well. There are more in-depth explanations below of the 'why' behind the way these are written.

Deploy just like you've always done with Terraform:
```bash
terraform init
terraform apply
```

# Notes

Below is various notes and info about each part of the Terraform code to give you context while you are exploring it or troubleshooting an issue in your environment.

## Backend

One of the benefits of using Harvester as an HCI is that it is powered by Kubernetes. Meaning all Kubernetes resources are available at your fingertips. We can use Kubernetes as a backend for storing Terraform state and that is what I use here.

Given that Terraform also has a provider for Kubernetes itself, we can use that to create standard KubeAPI objects like ConfigMaps, Secrets, Ingresses, etc. When delivering a cloud-init configuration to a Harvester virtual machine, there is a size limit if that config is defined inline. So instead we put it in a secret and reference it.

See the [provider.tf](./provider.tf) file to ensure your backend settings are correct (location of your kubeconfig specifically).
```hcl
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
  }
  backend "kubernetes" {
    secret_suffix    = "state-rke2"
    config_path      = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = var.local_kubeconfig
}
```

## Modules

In this code we minimize external providers as much as we can. I am using the Harvester provider, the Kubernetes provider and the SSH module. I have also crafted several inline modules around creating different node roles. 

By default, the Terraform code will only create a one-node Control-Plane but there is an `ha_mode` flag that can be set to true and it will create two more. The reason for the odd pattern here is because of some meta-ness going on with how nodes behave. While a control-plane can be 1-3-5-7-etc nodes in size, the very first control-plane node is still a little different than the others as it is not joining any other nodes. I like to call this first the `primary` node. Because its configuration differs slightly, I just use a flag to capture that. Are there better ways of doing it? Probably. Part of my job is knowing when to say when something is 'good enough' and its a little further back from the release line vs a front-line engineer.

## Load Balancing

Harvester provides some sophisticated load balancing capability now post-1.3. It uses Kubevip internally but wraps it up nicely to provide it to VMs and containers alike. It functions on the definition of an `IPPool` attached to a `LoadBalancer` object. If you want a very specific address, create the `IPPool` with that specific address. The provider does not yet expose these objects. We can use the Kubernetes provider to do this for us. The IP chosen for the load balancer should match the CIDR range of your host network for simplicity. There are ways of having VLAN-aware LBs but that requires L3 switching that goes beyond the scope of this repo.

However as of 1.3.0, Harvester does have one prescriptive requirement that prevents this from being used during inital HA control-plane provisioning. The back-end server selector config requires that the VMs be present before the LB can be created. There is a validator webhook sitting in the way preventing this. It seems that this has been removed in 1.3.1. So it is highly suggested you move to 1.3.1 if you have not already. There should be an upgrade button for migrating to 1.3.1 from 1.3.0 and 1.2.2.

Terraform also doesn't play as nice with dependencies and CRDs like the loadbalancing objects we need to create. So you will notice the yaml definitions for these objects is wrapped in a `helm_release` resource. This is not a real helm chart per-se, but is a good way to wrap and map their dependencies. This is important because `IPPool` must exist prior to a `LoadBalancer` object creation and the reverse also applies for deletion.

## VM Images

This module does not create the VM images. These are the QCOW2 images that Harvester uses as the core image for building a VM. I typically use Ubuntu as the cloud-images they release are reliable and lightweight (About 600mb). Feel free to use what you like, but keep in mind the image being used in Harvester must support cloud-init. Many hand-built 'golden-image' VMs are missing cloud-init as it is not always installed from a server iso.

## VM Networks

This module does not create the VM networks. You will need to create those based on your own needs. The simplest path is usually to create a 'host' network as Untagged attached to the Mgmt Cluster Network. This removes the need for any layer3 switching/intelligence. Provided your host network has DHCP on it, any VMs needing DHCP will be assigned as normal.

## Network Configuration on Guest OS

Harvester uses cloud-init for all VM-based configuration. And this means it uses the `network-data` field for what is commonly mentioned as `user-data`. If you're using DHCP, these fields can be left as empty strings. But for control plane nodes, it is highly recommended you use static IPs as `etcd` is highly dependent on those IPs never changing. If you've ever had to recover an `etcd` cluster whose member IPs changed, you know the headache I am talking about. 

The contents of this configuration are a bit more specific for the OS you are using. For example, Ubuntu uses netplan, which differs from RHEL/Rocky a bit with the configuration. 

This is further complicated by Terraform's usage of HCL as a descriptor language, even for its variables. In the `example.tfvars` file, I define an Ubuntu-centric network config but feel free to modify for another format. But this does contain the basic structure you need.




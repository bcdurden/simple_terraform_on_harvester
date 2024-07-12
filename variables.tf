variable "main_cluster_prefix" {
    type = string
    default = "rke2-mgmt-controlplane"
}
variable "worker_prefix" {
    type = string
    default = "rke2-mgmt-worker"
}
variable "kubeconfig_filename" {
    type = string
    default = "kube_config_server.yaml"
}
variable "rke2_version" {
    type = string
    default = "v1.28.10+rke2r1"
}
variable "registry_url" {
  type = string
  default = ""
}
variable "worker_count" {
  type = string
  default = 0
}
variable "node_disk_size" {
  type = string
  default = "40Gi"
}
variable "control_plane_ha_mode" {
  type = bool
  default = false
}
variable "control_plane_cpu_count" {
  type = string
  default = 2
}
variable "control_plane_memory_size" {
  type = string
  default = "8Gi"
}
variable "worker_cpu_count" {
  type = string
  default = 2
}
variable "worker_memory_size" {
  type = string
  default = "8Gi"
}
variable "harvester_rke2_image_name" {
  type = string
  default = "ubuntu"
}
variable "target_network_name" {
  type = string
}
variable "local_kubeconfig" {
  type = string
}
variable "lb_ip" {
  type = string
  description = "The LoadBalancer IP address you wish to provision"
}
variable "cp_network_data" {
  type = list
  description = "The network data configurations, a list of block strings"
  default = []
}
variable "cluster_token" {
  type = string
  description = "Token used for joining nodes"
  default = "my-cluster-token"
}
variable "ippools" {
  type = list
  description = "contains the yaml definition for IPPools"
}
variable "lb_spec" {
  type = list
  description = "contains the yaml definition for the LoadBalancers"
}
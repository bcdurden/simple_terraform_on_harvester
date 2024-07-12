variable "node_prefix" {
    type = string
}
variable "namespace" {
    type = string
    default = "default"
}
variable "disk_size" {
    type = string
    default = "40Gi"
}
variable "node_image_id" {
    type = string
}
variable "ssh_keys" {
    type = list
    default = []
}
variable "vlan_id" {
    type = string
}
variable "master_hostname" {
    type = string
    default = "rke2master"
}
variable "lb_ip" {
    type = string
    description = "The join IP"
}
variable "network_data" {
    type = string
    default = ""
}
variable "rke2_version" {
    type = string
    default = ""
}
variable "cluster_token" {
    type = string
}
variable "ssh_pubkey" {
    type = string
    default = ""
}
variable "ssh_key" {
    type = string
}
variable "worker_count" {
    type = number
    default = 3
}
variable "worker_node_core_count" {
    type = string
}
variable "worker_node_memory_size" {
    type = string
}
variable "rke2_registry" {
    type = string
    default = ""
}

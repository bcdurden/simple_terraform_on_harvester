variable "node_name_prefix" {
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
variable "lb_ip" {
    type = string
    description = "The join IP"
}
variable "network_data" {
    type = list
    default = []
}
variable "rke2_version" {
    type = string
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
    default = ""
}
variable "ha_mode" {
    type = bool
    default = false
}
variable "controlplane_node_core_count" {
    type = string
}
variable "controlplane_node_memory_size" {
    type = string
}
variable "rke2_registry" {
    type = string
    default = ""
}
variable "control_plane_labels" {
    type = string
}
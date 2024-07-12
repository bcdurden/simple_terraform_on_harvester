module "rke2-simple" {
  source  = "./modules/"
  depends_on = [
    helm_release.mgmt_lb
  ]
  
  main_cluster_prefix = var.main_cluster_prefix
  worker_prefix = var.worker_prefix
  kubeconfig_filename = var.kubeconfig_filename
  control_plane_ha_mode = var.control_plane_ha_mode
  worker_count = var.worker_count
  node_disk_size = var.node_disk_size
  control_plane_cpu_count = var.control_plane_cpu_count
  control_plane_memory_size = var.control_plane_memory_size
  worker_cpu_count = var.worker_cpu_count
  worker_memory_size = var.worker_memory_size
  harvester_rke2_image_name = var.harvester_rke2_image_name
  target_network_name = var.target_network_name
  registry_url = var.registry_url
  rke2_version = var.rke2_version
  lb_ip = var.lb_ip
  cluster_token = var.cluster_token

  control_plane_labels = <<EOT
            - "cluster-name=rancher-mgmt"
  EOT
  cp_network_data = var.cp_network_data
}
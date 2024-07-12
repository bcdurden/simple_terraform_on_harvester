resource "kubernetes_secret" "cp_main_config" {
  metadata {
    name = "${var.node_name_prefix}-cp-config"
  }

  type = "secret"

  data = {
    userdata = <<EOT
      #cloud-config
      write_files:
      - path: /etc/rancher/rke2/config.yaml
        owner: root
        content: |
          token: ${var.cluster_token}
          system-default-registry: ${var.rke2_registry}
          node-label: 
          ${var.control_plane_labels}
          tls-san:
            - ${var.node_name_prefix}-0
            - ${var.lb_ip}
          secrets-encryption: true
          write-kubeconfig-mode: 0640
          use-service-account-credentials: true
      - path: /etc/hosts
        owner: root
        content: |
          127.0.0.1 localhost
          127.0.0.1 ${var.node_name_prefix}-0
      runcmd:
      - curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${var.rke2_version} sh - 
      - systemctl enable rke2-server.service
      - systemctl start rke2-server.service
      ssh_authorized_keys: 
      - ${var.ssh_pubkey}
    EOT 
  }
}

resource "kubernetes_secret" "cp_ha_config" {
  count = var.ha_mode ? 2 : 0
  metadata {
    name = "${var.node_name_prefix}-cp-ha-config-${count.index + 1}"
  }

  type = "secret"

  data = {
    userdata = <<EOT
      #cloud-config
      package_update: true
      write_files:
      - path: /etc/rancher/rke2/config.yaml
        owner: root
        content: |
          token: ${var.cluster_token}
          server: https://${var.lb_ip}:9345
          system-default-registry: ${var.rke2_registry}
          node-label:
          ${var.control_plane_labels}
          tls-san:
            - ${var.node_name_prefix}-${count.index + 1}
            - ${var.lb_ip}
          secrets-encryption: true
          write-kubeconfig-mode: 0640
          use-service-account-credentials: true
      - path: /etc/hosts
        owner: root
        content: |
          127.0.0.1 localhost
          127.0.0.1 ${var.node_name_prefix}-${count.index + 1}
      runcmd:
      - curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${var.rke2_version} sh - 
      - systemctl enable rke2-server.service
      - systemctl start rke2-server.service
      ssh_authorized_keys: 
      - ${var.ssh_pubkey}
    EOT 
  }
}
resource "kubernetes_secret" "worker_config" {
  count = var.worker_count
  metadata {
    name = "${var.node_prefix}-worker-config-${count.index}"
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
          server: https://${var.lb_ip}:9345
          system-default-registry: ${var.rke2_registry}
          write-kubeconfig-mode: 0640
          kube-apiserver-arg:
          - authorization-mode=RBAC,Node
          kubelet-arg:
          - protect-kernel-defaults=true
          - read-only-port=0
          - authorization-mode=Webhook
      - path: /etc/hosts
        owner: root
        content: |
          127.0.0.1 localhost
          127.0.0.1 "${var.node_prefix}-${count.index}"
      runcmd:
      - curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${var.rke2_version} sh - 
      - systemctl enable rke2-agent.service
      - systemctl start rke2-agent.service
      ssh_authorized_keys: 
      - ${var.ssh_pubkey}
    EOT 
  }
}


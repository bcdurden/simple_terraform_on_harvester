output "ssh_key" {
    value = module.rke2-hardened.ssh_key
    sensitive = true
}
output "ssh_pubkey" {
    value = module.rke2-hardened.ssh_pubkey
}
output "kube" {
    value = module.rke2-hardened.kube
    sensitive = true
}
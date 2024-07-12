resource "helm_release" "ippool" {
  name       = "lb-ip-pool"
  repository = "https://charts.itscontained.io"
  chart      = "raw"
  version    = "0.2.5"
  values = var.ippools
}
resource "helm_release" "mgmt_lb" {
  depends_on = [helm_release.ippool]
  name       = "lb-ip-pool"
  repository = "https://charts.itscontained.io"
  chart      = "raw"
  version    = "0.2.5"
  values = var.lb_spec
}
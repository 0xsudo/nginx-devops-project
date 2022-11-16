resource "helm_release" "prod-cluster" {
  name  = "prod-cluster"
  chart = ".Chart.yaml"
}
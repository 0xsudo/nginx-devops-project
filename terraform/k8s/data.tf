data "aws_eks_cluster" "prod-cluster" {
  name = module.prod-cluster.cluster_id
}

data "aws_eks_cluster_auth" "prod-cluster" {
  name = module.prod-cluster.cluster_id
}
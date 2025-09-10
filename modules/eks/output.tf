output "cluster_endpoint" {
  value = aws_eks_cluster.my-cluster.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.my-cluster.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.my-cluster.name
}
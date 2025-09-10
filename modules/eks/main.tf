resource "aws_eks_cluster" "my-cluster" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  # version  = "1.29"

  vpc_config {
    subnet_ids = var.eks_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  tags ={
    Name = "my-app-cluster"
  }
  depends_on = [ aws_iam_policy_attachment.eks_cluster_amazonEksClusterPolicy ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "role-for-my-app-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "eks_cluster_amazonEksClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles = [aws_iam_role.eks_cluster_role.name]
  name = "policy-attch-eks-cluster"
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# data "aws_ssm_parameter" "eks_worker_ami" {
#   name = "/aws/service/eks/optimized-ami/1.32/amazon-linux-2/recommended/image_id"
# }

# resource "aws_launch_template" "eks_node_ec2" {
#   name_prefix   = "eks-node-ec2-"
#   image_id      = data.aws_ssm_parameter.eks_worker_ami.value
#   instance_type = "t3.medium"

#   vpc_security_group_ids = var.node_group_sg_id

#   user_data = base64encode(<<-EOT
#     #!/bin/bash
#     /etc/eks/bootstrap.sh ${aws_eks_cluster.my-cluster.name}
#   EOT
#   )

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       volume_size           = 20
#       volume_type           = "gp3"
#       delete_on_termination = true
#     }
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "eks-node"
#     }
#   }
# }


resource "aws_eks_node_group" "node_group" {
  cluster_name = aws_eks_cluster.my-cluster.name
  node_group_name = "node-group-for-app-cluster"
  node_role_arn = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids = var.eks_subnet_ids
  instance_types = ["t3.medium"]
  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }
 
  depends_on = [ aws_eks_cluster.my-cluster ]
  # launch_template {
  #   id      = aws_launch_template.eks_node_ec2.id
  #   version = "$Latest" 
  # }
  
}
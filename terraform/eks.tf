data "aws_iam_role" "eks_cluster_role" {
  name = "AmazonEKSAutoClusterRole"
}

data "aws_iam_role" "eks_node_role" {
  name = "AmazonEKSAutoNodeRole"
}

resource "aws_eks_cluster" "main" {
  name     = "my-eks-cluster"
  role_arn = data.aws_iam_role.eks_cluster_role.arn
  version  = "1.34"

  vpc_config {

    subnet_ids = module.vpc.private_subnets
    
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "eks-nodegroup-private"
  node_role_arn   = data.aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]


  update_config {
    max_unavailable = 1
  }
}

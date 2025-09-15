variable "eks_subnet_ids" {
  type = list(string)
}

variable "cluster_name" {
  default = "eks-app-cluster"
}

variable "desired_size" {
  description = "value"
}

variable "max_size" {
 description = "value"
}

variable "min_size" {
  description = "value"
}

# variable "security_group_for_lb" {
#   description = "sg"
# }

# variable "node_group_sg_id" {
#   description = "value"
#   type = list(string)
# }


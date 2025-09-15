variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# variable "public_cidr" {
#   default = "10.0.1.0/24"
# }

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.4.0/24"]
}

variable "public_availability_zones" {
  type = list(string)
  default = [ "us-east-1a", "us-east-1b"]
}

# variable "eks_nodes_sg" {
#   type = list(string)
# }
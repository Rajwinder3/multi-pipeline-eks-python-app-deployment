variable "db_username" {
  type = string
  description = "username of rds"
  default = "admin"
}

variable "db_password" {
  type = string
  description = "password for rds"
  
}

variable "desired_size" {
  default = 3
}

variable "max_size" {
  default = 2
}

variable "min_size" {
  default = 1
}
variable "username" {
  description = "Master DB username"
  type        = string
}

variable "password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "private_subnet" {
  type = list(string)
}

variable "security_group" {
  type = list(string)
}
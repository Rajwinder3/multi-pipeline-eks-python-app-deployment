output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "sg_private" {
value       = aws_security_group.private_Sg.id
}

output "sg_public" {
  value = aws_security_group.public_Sg.id
}

output "public_Subnet_ids" {
  value = aws_subnet.public[*].id
}
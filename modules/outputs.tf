output "subnet1_id" {
  value = aws_subnet.eks_public_sub_one.id
}

output "subnet2_id" {
  value = aws_subnet.eks_public_sub_two.id
}

output "subnet3_id" {
  value = aws_subnet.eks_private_sub_one.id
}

output "subnet4_id" {
  value = aws_subnet.eks_public_sub_two.id
}
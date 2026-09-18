output "instance_id" {
  value = aws_instance.ec2_instance.id
}

output "instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}
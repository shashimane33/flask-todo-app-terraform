output "instance_id" {
    description = "instance-id of ec2 instance"
    value = aws_instance.myec2.id
}
output "instance_public_ip" {
    description = "public ip address assigned to instance"
    value = aws_instance.myec2.public_ip
}
output "security_group_id" {
    description = "security group id"
    value = aws_security_group.sg1.id
}
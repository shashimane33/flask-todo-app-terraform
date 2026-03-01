output "frontend_instance_id" {
    description = "instance-id of ec2 instance for frontend"
    value = aws_instance.frontend-ec2.id
}
output "frontend_instance_public_ip" {
    description = "public ip address assigned to frontend instance"
    value = aws_instance.frontend-ec2.public_ip
}
output "backend_instance_id" {
    description = "instance-id of ec2 instance for backend"
    value = aws_instance.backend-ec2.id
}
output "backend_instance_public_ip" {
    description = "public ip address assigned to backend instance"
    value = aws_instance.backend-ec2.public_ip
}
output "security_group_id" {
    description = "security group id"
    value = aws_security_group.sg1.id
}
output "frontend_running_on" {
    value = "http://${aws_instance.frontend-ec2.public_ip}:3000"
}
output "backend_running_on" {
    value = "http://${aws_instance.backend-ec2.public_ip}:5000"
}
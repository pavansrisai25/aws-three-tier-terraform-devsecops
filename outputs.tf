
output "vpc_id" {
  description = "Three-tier VPC ID"
  value       = aws_vpc.main.id
}

output "public_alb_dns" {
  description = "Public Application Load Balancer DNS"
  value       = aws_lb.main.dns_name
}

output "application_url" {
  description = "Public application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "internal_alb_dns" {
  description = "Internal Application Load Balancer DNS"
  value       = aws_lb.app.dns_name
}

output "web_asg_name" {
  description = "Web Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  description = "Application Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "rds_endpoint" {
  description = "Private RDS MySQL endpoint"
  value       = aws_db_instance.mysql.address
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "application_subnet_ids" {
  description = "Private application subnet IDs"
  value = [
    aws_subnet.app_a.id,
    aws_subnet.app_b.id
  ]
}

output "database_subnet_ids" {
  description = "Private database subnet IDs"
  value = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]
}

# Backward-compatible outputs from the original project

output "alb_dns_name" {
  description = "Original public ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Original public ALB URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "web_a_private_ip" {
  description = "Private IP of existing EC2 instance A"
  value       = aws_instance.web_a.private_ip
}

output "web_b_private_ip" {
  description = "Private IP of existing EC2 instance B"
  value       = aws_instance.web_b.private_ip
}
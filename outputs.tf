output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb_internship_dinh.dns_name
}

output "identity_pool_id" {
  description = "Cognito identity ID"
  value = aws_cognito_identity_pool.cognito_internship_dinh.id
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mysql.endpoint
}
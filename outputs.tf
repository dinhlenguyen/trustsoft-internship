output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb_internship_dinh.dns_name
}

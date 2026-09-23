output "frontend_url" {
  description = "Public URL for the deployed frontend"
  value       = "http://${aws_lb.main.dns_name}"
}

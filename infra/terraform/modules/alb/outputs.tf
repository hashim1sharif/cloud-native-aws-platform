output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.application_load_balancer.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.application_load_balancer.arn
}

output "load_balancer_zone_id" {
  description = "Route 53 hosted zone ID of the Application Load Balancer."
  value       = aws_lb.application_load_balancer.zone_id
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group."
  value       = aws_lb_target_group.frontend_target_group.arn
}

output "backend_target_group_arn" {
  description = "ARN of the backend target group."
  value       = aws_lb_target_group.backend_target_group.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener that redirects traffic to HTTPS."
  value       = aws_lb_listener.http_listener.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener."
  value       = aws_lb_listener.https_listener.arn
}

output "https_backend_api_listener_rule_arn" {
  description = "ARN of the HTTPS listener rule that routes API traffic to the backend target group."
  value       = aws_lb_listener_rule.https_backend_api_listener_rule.arn
}
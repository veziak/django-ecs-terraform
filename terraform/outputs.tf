output "alb_hostname" {
  value = aws_lb.load_balancer.dns_name
}

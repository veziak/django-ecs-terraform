# Production Load Balancer
resource "aws_lb" "load_balancer" {
  name               = "${var.ecs_cluster_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.lb_secuirity_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

# Target group
resource "aws_lb_target_group" "default_target_group" {
  name        = "${var.ecs_cluster_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}

# Listener (redirects traffic from the load balancer to the target group)
resource "aws_alb_listener" "ecs_alb_http_listener" {
  load_balancer_arn = aws_lb.load_balancer.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.acm_cert_validation.certificate_arn
  depends_on        = [aws_lb_target_group.default_target_group]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_target_group.arn
  }
}

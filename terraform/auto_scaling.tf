resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "${var.ecs_cluster_name}_auto_scaling_group"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}
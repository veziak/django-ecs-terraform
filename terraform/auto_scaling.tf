resource "aws_launch_configuration" "ecs_launch_config" {
  name                        = "${var.ecs_cluster_name}-launch-config"
  image_id                    = data.aws_ssm_parameter.recommended_linux_ami.value
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ecs_secuirity_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  key_name                    = aws_key_pair.ec2_ssh_key_pair.key_name
  associate_public_ip_address = false
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${var.ecs_cluster_name} > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "ecs_asg"
  vpc_zone_identifier       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  launch_configuration      = aws_launch_configuration.ecs_launch_config.name
  desired_capacity          = var.autoscale_desired
  min_size                  = var.autoscale_min
  max_size                  = var.autoscale_max
  health_check_grace_period = 300
  health_check_type         = "EC2"
}
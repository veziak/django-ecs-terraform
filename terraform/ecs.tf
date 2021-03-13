resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.ecs_cluster_name}-cluster"
}

data "template_file" "task_definition_template" {
  template = file("templates/django_app.json.tpl")

  vars = {
    docker_image_url_django = var.docker_image_url_django
    docker_image_url_nginx  = var.docker_image_url_nginx
    region                  = var.region
    rds_db_name             = var.rds_db_name
    rds_username            = var.rds_username
    rds_password_secret_arn = aws_ssm_parameter.rds_password_ssm.arn
    rds_hostname            = aws_db_instance.db_instance.address
    allowed_hosts           = var.allowed_hosts
    debug                   = var.django_debug
  }
}

resource "aws_ecs_task_definition" "django_app_task_definition" {
  family                   = "django-app"
  container_definitions    = data.template_file.task_definition_template.rendered
  depends_on               = [aws_db_instance.db_instance]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.ecs_cluster_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.django_app_task_definition.arn
  //iam_role        = aws_iam_role.ecs_service_role.arn
  desired_count = var.app_count
  launch_type   = "FARGATE"
  depends_on    = [aws_alb_listener.ecs_alb_http_listener, aws_iam_role_policy.ecs_service_role_policy]

  network_configuration {
    security_groups  = [aws_security_group.ecs_secuirity_group.id]
    subnets          = [aws_subnet.private_subnet_1.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.default_target_group.arn
    container_name   = "nginx"
    container_port   = 80
  }
}

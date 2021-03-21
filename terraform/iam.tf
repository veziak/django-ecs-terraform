resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = file("policies/ecs-task-execution-role.json")
}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "ecs_task_execution_role_policy"
  policy = file("policies/ecs-task-execution-role-policy.json")
  role   = aws_iam_role.ecs_task_execution_role.id
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs_service_role.id
}

# ecs instance

data "aws_iam_policy_document" "ecs_instance_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs.amazonaws.com",]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ec2_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance"
  path = "/"
  role = aws_iam_role.ecs_instance_role.name
}
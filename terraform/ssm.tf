resource "aws_ssm_parameter" "rds_password_ssm" {
  name        = "/database/${var.rds_db_name}/password"
  description = "Password for ${var.rds_db_name} database"
  type        = "SecureString"
  value       = random_password.rds_password.result
}

data "aws_ssm_parameter" "recommended_linux_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
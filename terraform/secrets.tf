resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_ssm_parameter" "rds_password_ssm" {
  name        = "/database/${var.rds_db_name}/password"
  description = "Password for ${var.rds_db_name} database"
  type        = "SecureString"
  value       = random_password.rds_password.result
}
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
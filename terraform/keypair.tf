resource "aws_key_pair" "key_pair" {
  key_name   = "${var.ecs_cluster_name}_key_pair"
  public_key = file(var.ssh_pubkey_file)
}

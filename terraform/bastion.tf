module "bastion" {
  source            = "github.com/jetbrains-infra/terraform-aws-bastion-host"
  subnet_id         = aws_subnet.public_subnet_1.id
  ssh_key           = aws_key_pair.ec2_ssh_key_pair.key_name
  allowed_hosts     = [var.bastion_allowed_cidr]
  internal_networks = [var.private_subnet_1_cidr, var.private_subnet_2_cidr]
  disk_size         = 10
  instance_type     = "t2.nano"
  project           = "myProject"
}
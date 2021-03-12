resource "aws_route53_record" "route53_cname_record" {
  zone_id = data.aws_route53_zone.route53_zone.id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.load_balancer.dns_name]
}
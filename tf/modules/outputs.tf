output "F5 standalone IP" {
    value = "${aws_instance.f5_standalone.public_ip}"
}
output "F5 server FQDN" {
    value = "${aws_route53_record.f5_dns.fqdn}"
}

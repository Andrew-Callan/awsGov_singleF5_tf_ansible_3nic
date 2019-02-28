output "F5 standalone IP" {
    value = "${aws_instance.f5_standalone.public_ip}"
}


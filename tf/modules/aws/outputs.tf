output "f5_mgmt_ip"{
  value = "${aws_instance.bigip_standalone.public_ip}"
}

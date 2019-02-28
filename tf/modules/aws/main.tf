provider "aws" {
  region = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

#### Commerical AWS provider for Route53 ####
## to utilize this, you will need to uncomment the cooresponding variables in variables.tf
#provider "aws" {
#  alias = "${var.provider_alias}"
#  region = "${var.alt_region}"
#  access_key = "${var.alt_aws_access_key}"
#  secret_key = "${var.alt_aws_secret_key}"
#
#}

### Security Group (Firewall) rules ###

resource "aws_security_group" "f5_mgmt_ssh" {
  vpc_id = "${var.vpc_id}"
  name = "f5 allow ssh"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name  = "f5_mgmt"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "f5_mgmt_https" {
  vpc_id = "${var.vpc_id}"
  name = "f5 allow https 443 and 8443"

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "8443"
    to_port     = "8443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name  = "f5_mgmt"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "f5_mgmt_iquery" {
  vpc_id = "${var.vpc_id}"
  name = "f5_iquery"

  ingress {
    from_port   = "4353"
    to_port     = "4353"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name  = "f5_mgmt"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "f5_internal_allow_all_internal" {
  vpc_id = "${var.vpc_id}"
  name = "allow_all_internal"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name  = "f5_mgmt"
    Owner = "${var.owner}"
  }
}


resource "aws_eip" "f5_mgmt" {
  vpc      = true
  network_interface         = "${aws_instance.bigip_standalone.primary_network_interface_id}"
  associate_with_private_ip = "${aws_instance.bigip_standalone.private_ip}"

}

# resource "aws_eip" "vs1_eip" {
#   vpc      = true
#   network_interface         = "${aws_network_interface.bigip_external_interface.id}"
#   associate_with_private_ip = "${var.vs_1}"
#
# }

resource "aws_network_interface" "bigip_external_interface" {
  subnet_id       = "${var.external_subnet_id}"
  private_ips     = ["${var.external_ip}"]
  security_groups = ["${aws_security_group.f5_mgmt_https.id}"]
  attachment {
    instance     = "${aws_instance.bigip_standalone.id}"
    device_index = 1
  }
}

resource "aws_network_interface" "bigip_internal_interface" {
  subnet_id       = "${var.internal_subnet_id}"
  private_ips     = ["${var.internal_ip}"]
  security_groups = ["${aws_security_group.f5_internal_allow_all_internal.id}"]

  attachment {
    instance     = "${aws_instance.bigip_standalone.id}"
    device_index = 2
  }
}

resource "aws_instance" "bigip_standalone" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  subnet_id                   = "${var.mgmt_subnet_id}"
  root_block_device { delete_on_termination = true }
  vpc_security_group_ids = ["${aws_security_group.f5_mgmt_ssh.id}", "${aws_security_group.f5_mgmt_https.id}", "${aws_security_group.f5_mgmt_iquery.id}","${aws_security_group.f5_internal_allow_all_internal.id}"]

  tags {

    Name    = "${var.project}"
    Owner   = "${var.owner}"
    Project = "${var.project}"
    Role    = "bigip"

  }
}


#resource "aws_route53_record" "f5_dns" {
#  provider = "aws.${var.provider_alias}"
#  zone_id = "${var.dns_zone}"
#  name    = "${var.dns_name}"
#  type    = "A"
#  ttl     = "300"
#  records = ["${aws_instance.bigip_standalone.public_ip}"]
#}

#resource "aws_route53_record" "f5_vs1_dns" {
#  provider = "aws.${var.provider_alias}"
#  zone_id = "${var.dns_zone}"
#  name    = "govoseapp1"
#  type    = "A"
#  ttl     = "300"
#  records = ["${aws_eip.vs1_eip.public_ip}"]
#}

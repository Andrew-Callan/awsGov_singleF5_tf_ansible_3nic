variable "owner" { default = "" }
variable "project" { default = "" }
variable "region" { default = "us-gov-west-1" }
variable "tag" { default = "" }
variable "aws_access_key" {default = "" }
variable "aws_secret_key" {default = "" }
#variable "alt_aws_access_key" { default = "" }
#variable "alt_aws_secret_key" { default = "" }
variable "vpc_id" { default = "" }
variable "mgmt_subnet_id" { default = "" }
variable "external_subnet_id" { default = "" }
variable "internal_subnet_id" { default = "" }
variable "ami" { default = "" }
variable "key_name" { default = "" }
variable "instance_type" { default = "m5.large" }
# variable "provider_alias" {default = "" }
variable "az" { default = ""}
#variable "alt_region" { default = "us-east-1" }
variable "external_ip" { default = "" }
variable "internal_ip" { default = "" }
#variable "dns_zone" { default = "" }
#variable "dns_name" {default = ""}

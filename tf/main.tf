terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

## Local Vars
locals {
  all_config_files = fileset(path.module, "../metadata/${var.environ}/*.yml")
  cloud_configs = {
    for file in local.all_config_files :
    yamldecode(file(file))["tf_unique_id"] => yamldecode(file(file))
  }

}

/*
module "local_vm" {

  #for_each = local.cloud_configs
  for_each = {
    for k,v in local.cloud_configs: k=>v 
    if v["kind"] == "ec2-instance" ? true: false
  }


  #source           = "git::https://github.com/prjteresi/terraform-aws-ec2-instance.git?ref=1.0.1"
  source           = "git::https://github.com/prjteresi/terraform-aws-ec2-instance.git?ref=1.0.0"
  vpc_id           = each.value["vpc_id"]
  vm_subnet_cidr   = each.value["vm_subnet_cidr"]
  vm_name          = each.value["vm_name"]
  #vm_instance_type = each.value["vm_instance_type"]
}
*/

module "ec2-instance" {
  source  = "app.terraform.io/level20-devops/ec2-instance/aws"
  version = "1.0.1"

  for_each = {
    for k,v in local.cloud_configs: k=>v 
    if v["kind"] == "ec2-instance" ? true: false
  }

  vpc_id           = each.value["vpc_id"]
  vm_subnet_cidr   = each.value["vm_subnet_cidr"]
  vm_name          = each.value["vm_name"]
  vm_instance_type = each.value["vm_instance_type"]
}



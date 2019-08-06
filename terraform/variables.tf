variable "region" {
  default = "eu-west-1"
}

variable "vpc" {
  type = "map"
  default = {
    "cidr_block" = "10.10.0.0/16"
    "name"       = "sgtask"
  }
}

variable "public_subnets" {
  type = "map"
  default = {
    "1" = "10.10.0.0/20"
    "2" = "10.10.16.0/20"
    "3" = "10.10.32.0/20"
  }
}

variable "private_subnets" {
  type = "map"
  default = {
    "1" = "10.10.48.0/20"
    "2" = "10.10.64.0/20"
    "3" = "10.10.80.0/20"
  }
}

variable "worker_nodes" {
  type = "map"
  default = {
    "ami"           = "ami-08716b70cac884aaa"
    "instance_type" = "m5.xlarge"
    "key_name"      = "<AWS_KEY>"
    "root_vol_size" = "30"
    "label"         = "general"
    "capacity"      = "2"
  }
}

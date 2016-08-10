variable "aws_region" {
	default = "eu-west-1"
}

variable "env" {
	type = "map"
	default {
		name = "test"
		cidr = "10.0.0.0/16"
		number_of_public_subnets = 2
		number_of_private_subnets = 4
	}
}

variable "az" {
	default = {
	  "zone0" = "eu-west-1a"
	  "zone1" = "eu-west-1b"
	  "zone2" = "eu-west-1a"
	  "zone3" = "eu-west-1b"
	}
}

variable "public_cidr" {
  default = {
    "zone0" = "10.0.1.0/24"
    "zone1" = "10.0.2.0/24"
  }
}

variable "private_cidr" {
  default = {
    "zone0" = "10.0.5.0/24"
    "zone1" = "10.0.6.0/24"
    "zone2" = "10.0.7.0/24"
		"zone3" = "10.0.8.0/24"
  }
}

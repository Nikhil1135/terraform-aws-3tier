variable "region" {
  default = "us-east-1"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  description = "Map of AZs to CIDR blocks for public subnets"
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
  }
}

variable "private_subnet" {
  description = "Map of AZs to CIDR blocks for private subnets"
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.3.0/24"
    "us-east-1b" = "10.0.4.0/24"
  }
}

variable "ami" {
  type = string
  default = "ami-01b14b7ad41e17ba4"
}
variable "instance_type" {
  type = string
  default = "t2.micro"
}
# variable "subnet_id" {
#   default = module.vpc.public_subnet_ids[0]
# }
variable "key_name" {
  type = string
  default = "win-key"
}



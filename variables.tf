variable "region" {
  default = "us-east-1"
}

variable "cidr_block" {
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

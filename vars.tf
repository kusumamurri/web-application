variable "aws_region" {
  description = "Mumbai"
  default     = "ap-south-1"                                          #Add Region of your preference
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}	

variable "key" {
    default = "EC2 Tutorial"                                     # Insert your key
}

variable "azs" {
  type = list
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]            # Add availability zones in that region
}

variable "public_subnets_cidr" {
  type = list
  default = ["10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24"]
}

variable "private_subnets_cidr" {
  type = list
  default = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
}

variable "alarms_email" {
}                               

#####################################
# Variables 
# Overwritten by environment settings
# found in the dev/stage/live areas
######################################

###### Provider Information
variable aws_access_key {}
variable aws_secret_key {}

variable region {
    default = "eu-west-2"
}


##### Common Variables

# Network Name used for preluding names
variable networkname {}
# location environment - dev / stage / live
variable location_env {}

# Client name for prefixes
variable account_name {}

variable tags {
    type = string
    default = "blah"
}

##### Network Variables
variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type = string
}
variable "public_subnets" {
    description = "List of PUBLIC subnets for the VPC"
    type = list(string)
}
variable "aws_az" {
    description = "List of availability zone names in this region"
    type = list(string)
}

variable "private_subnets" {
    description = "List of PRIVATE subnets for the VPC"
    type = list(string)
}
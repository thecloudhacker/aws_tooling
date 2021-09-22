#####################################
# Default Variables 
# Overwritten by environment settings
# found in the variables.tfvars file
######################################

###### Provider Information
variable aws_access_key {}
variable aws_secret_key {}

variable region {
    default = "eu-west-2"
}

# location environment - dev / stage / live
variable location_env {}

# client or account name for customising the resource names
variable account_name{
    default = "itsm"
}
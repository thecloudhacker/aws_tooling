terraform{
    backend "s3" {
        region = "eu-west-2"
        bucket     = var.tf_state_bucket
    }
}

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}

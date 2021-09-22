######### BUCKET SETUP FOR TERRAFORM

resource "aws_s3_bucket" "terrabucket" {
  bucket = join("", [lower(var.account_name), "-terraform"] )
  acl    = "private"

  tags = {
    Name        = join("", [lower(var.account_name), "-terraform"] )
    environment-type = var.location_env
    classification  = "confidential"
    owner       = "gingerco"
  }

  versioning {
    enabled = true
  }


}
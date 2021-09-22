######### BUCKET SETUP FOR LOG STORAGE

resource "aws_s3_bucket" "logbucket" {
  bucket = join("", [lower(var.account_name), "-logs"] )
  acl    = "private"

  tags = {
    Name        = join("", [lower(var.account_name), "-logs"] )
    environment-type = var.location_env
    classification  = "confidential"
    owner       = "gingercoder"
  }

  versioning {
    enabled = true
  }


}
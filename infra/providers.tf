provider "aws" {
  region = var.region

  dynamic "endpoints" {
    for_each = var.local_test ? [1] : []
    content {
      ec2            = "http://localhost:4566"
      eks            = "http://localhost:4566"
      iam            = "http://localhost:4566"
      sts            = "http://localhost:4566"
      s3             = "http://localhost:4566"
      dynamodb       = "http://localhost:4566"
      cloudwatch     = "http://localhost:4566"
      cloudformation = "http://localhost:4566"
      # Add other services as needed
    }
  }

  skip_credentials_validation = var.local_test
  skip_metadata_api_check     = var.local_test
  skip_requesting_account_id  = var.local_test
  s3_use_path_style           = var.local_test
  access_key                  = var.local_test ? "test" : null
  secret_key                  = var.local_test ? "test" : null
}

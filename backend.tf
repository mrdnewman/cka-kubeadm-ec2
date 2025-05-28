
terraform {
  backend "s3" {
    bucket         = "my-cka-lab-bucket"
    key            = "cka-lab/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-lock-table"
    encrypt        = true
  }
}





# sinle user lock. No DB table needed

terraform {
  backend "s3" {
    bucket       = "my-cka-lab-bucket"
    key          = "cka-lab/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

# Multi user lock. requires DB table

#terraform {
#  backend "s3" {
#    bucket         = "my-cka-lab-bucket"
#    key            = "cka-lab/terraform.tfstate"
#    region         = "us-west-2"
#    dynamodb_table = "tf-lock-table"
#    encrypt        = true
#  }
#}




## Bucket and DB need to be created manually

# Create the S3 bucket:
# aws s3api create-bucket --bucket my-cka-lab-bucket --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2

# Create the DynamoDB table for locking:
# aws dynamodb create-table \
#  --table-name tf-lock-table \
#  --attribute-definitions AttributeName=LockID,AttributeType=S \
#  --key-schema AttributeName=LockID,KeyType=HASH \
#  --billing-mode PAY_PER_REQUEST \
#  --region us-west-2


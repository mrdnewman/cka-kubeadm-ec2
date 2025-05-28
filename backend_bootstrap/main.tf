
# Fire off this first: Auto create bucket and DB table
# Once this succeeds, delete or ignore this folder — it's done its job.

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "my-cka-lab-bucket"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "cka-lab"
  }
}

resource "aws_s3_bucket_acl" "tf_state_acl" {
  bucket = aws_s3_bucket.tf_state.id
  acl    = "private"
}

# Use only for DB locking

#resource "aws_dynamodb_table" "tf_lock" {
#  name         = "tf-lock-table"
#  billing_mode = "PAY_PER_REQUEST"
#  hash_key     = "LockID"
#
#  attribute {
#    name = "LockID"
#    type = "S"
#  }
#}

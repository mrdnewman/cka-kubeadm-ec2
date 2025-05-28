

resource "aws_s3_bucket" "tf_state" {
  bucket = "my-unique-tf-state-bucket-12345"  # Must be globally unique
  acl    = "private"
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "tf-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}


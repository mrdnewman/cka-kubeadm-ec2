
resource "aws_s3_bucket" "tf_state" {
  bucket = "my-cka-lab-bucket"
}

resource "aws_s3_bucket_acl" "tf_state_acl" {
  bucket = aws_s3_bucket.tf_state.id
  acl    = "private"
}

# Don't need. Usin single user lock
# Lock takes place on the local lap top

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

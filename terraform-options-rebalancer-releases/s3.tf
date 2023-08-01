resource "aws_s3_bucket" "options_rebalancer_releases" {
  bucket = "test-releases"

}

resource "aws_s3_bucket_public_access_block" "options_rebalancer_releases_access_block" {
  bucket = aws_s3_bucket.options_rebalancer_releases.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "options_rebalancer_releases_lifecycle" {
  rule {
    id                                     = "archive"
    status                                 = "Enabled"
    abort_incomplete_multipart_upload_days = 7

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2557 # 7 years
    }
  }
  bucket = aws_s3_bucket.options_rebalancer_releases.id
}

resource "aws_s3_bucket" "s3" {
  bucket = "web-server-${random_pet.petname.id}"

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "s3_config" {
    bucket = aws_s3_bucket.s3.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }

    depends_on = [ aws_s3_bucket_acl.s3_acl ]
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.s3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_access" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
  ]

  bucket = aws_s3_bucket.s3.id
  acl    = "public-read"
}

resource "aws_s3_object" "object" {
  for_each = fileset("assets", "**")

  bucket = aws_s3_bucket.s3.id
  key    = each.key
  source = "assets/${each.key}"
  acl = "public-read"
  etag = filemd5("assets/${each.key}")
#   content_type = lookup(local.content_type_map, split(".", "assets/${each.value}")[1], "text/html")
}


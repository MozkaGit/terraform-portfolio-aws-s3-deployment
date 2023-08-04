resource "aws_s3_bucket" "s3" {
  bucket = "web-server-${random_pet.petname.id}"

  tags = var.tags
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

resource "aws_s3_object" "index" {
  depends_on = [
    aws_s3_bucket.s3,
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
    aws_s3_bucket_acl.s3_acl,
  ]
  bucket       = aws_s3_bucket.s3.id
  key          = "index.html"
  source       = "www/index.html"
  acl          = "public-read"
  etag         = filemd5("www/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  depends_on = [
    aws_s3_bucket.s3,
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
    aws_s3_bucket_acl.s3_acl,
  ]
  bucket       = aws_s3_bucket.s3.id
  key          = "error.html"
  source       = "www/error.html"
  acl          = "public-read"
  etag         = filemd5("www/error.html")
  content_type = "text/html"
}

locals {
  website_files = fileset("www/assets/", "**")

  mime_types = jsondecode(file("mime.json"))
}

resource "aws_s3_object" "assets" {
  depends_on = [
    aws_s3_bucket.s3,
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
    aws_s3_bucket_acl.s3_acl,
  ]
  for_each = fileset("www/assets/", "**")
  bucket   = aws_s3_bucket.s3.id
  key      = each.key
  source   = "www/assets/${each.key}"
  acl      = "public-read"
  etag     = filemd5("www/assets/${each.key}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.key), null)
}

resource "aws_s3_bucket_website_configuration" "s3_config" {
  depends_on = [aws_s3_bucket_acl.s3_acl]
  bucket     = aws_s3_bucket.s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
  provisioner "local-exec" {
    command = "echo http://${aws_s3_bucket_website_configuration.s3_config.website_endpoint} >> endpoint.txt"
  }
}


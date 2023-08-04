# Define an AWS S3 bucket with a random name generated from random_pet.petname.id
resource "aws_s3_bucket" "s3" {
  bucket = "web-server-${random_pet.petname.id}"

  tags = var.tags
}

# Configuring S3 bucket property controls
resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.s3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configuring S3 bucket public access blocking
resource "aws_s3_bucket_public_access_block" "s3_access" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configuring S3 bucket ACL to allow public reading
resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
  ]

  bucket = aws_s3_bucket.s3.id
  acl    = "public-read"
}

# Uploading HTML files to the S3 bucket
resource "aws_s3_object" "html" {
  depends_on = [
    aws_s3_bucket.s3,
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
    aws_s3_bucket_acl.s3_acl,
  ]
  for_each = fileset("www/", "*html") # create a loop to retrieve all HTML files in the "www" directory
  bucket       = aws_s3_bucket.s3.id
  key          = each.key
  source       = "www/${each.key}" # the parameter each.key refers to the for_each defined on line 46
  acl          = "public-read"
  etag         = filemd5("www/${each.key}")
  content_type = "text/html" # set the content type so that it is correctly displayed in the browser
}

# In this case, the contents of the "www/assets/" folder are mapped to the content type defined in the "mime.json" file.
locals {
  website_files = fileset("www/assets/", "**")

  mime_types = jsondecode(file("mime.json"))
}

# Upload files contained in the "www/assets/" folder
resource "aws_s3_object" "assets" {
  depends_on = [
    aws_s3_bucket.s3,
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
    aws_s3_bucket_acl.s3_acl,
  ]
  for_each = fileset("www/assets/", "**") # create a loop to retrieve all files in the "www/assets/" directory
  bucket   = aws_s3_bucket.s3.id
  key      = each.key
  source   = "www/assets/${each.key}" # the parameter "each.key" refers to the "for_each" defined on line 70
  acl      = "public-read"
  etag     = filemd5("www/assets/${each.key}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.key), null) # use lookup to retrieve the appropriate content type using "mime.json".
}

# Configuring the S3 bucket as a static website
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
    command = "echo http://${aws_s3_bucket_website_configuration.s3_config.website_endpoint} > endpoint.txt"
  }
}

# To print the bucket's website URL after creation
output "website_endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.s3_config.website_endpoint}"
}
variable "bucket_name" {
  description = "name of S3 bucket"
  default = "NULL"
}

variable "tags" {
  description = "tags to set on the bucket."
  default     = {}
}
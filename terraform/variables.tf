variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_repo" {
  description = "owner/repo"
  type        = string
}

variable "github_allowed_branches" {
  description = "Branches that can assume the role"
  type        = list(string)
  default = [
    "main",
    "feature/*",
    "feat/*"
  ]
}

variable "tf_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

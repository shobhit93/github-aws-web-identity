# Terraform variables for local use

aws_region  = "eu-west-1"
github_repo = "shobhit93/github-aws-web-identity"
github_allowed_branches = [
  "main",
  "feature/*",
  "feat/*",
]

tf_state_bucket = "github-aws-web-identity-terraform-state"

tags = {
  Environment = "prod"
  Owner       = "shobhit93"
  Project     = "github-aws-web-identity"
}

variable "environment_name" {
  description = "Logical environment label (not consistently applied to resources below)."
  type        = string
  default     = "shared"
}

variable "aws_region" {
  description = "AWS region for provider configuration."
  type        = string
  default     = "us-west-2"
}

variable "ecr_repository_name" {
  description = "Preferred ECR repository name (currently unused; repository name is set in main.tf locals)."
  type        = string
  default     = "devops-testdrive-static-site"
}

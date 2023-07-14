variable "aws_account_id" {
  default = "936066658209"
}
variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"  
}

variable "subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"] 
}


variable "github_repo_owner" {
  default = "vanshgulati16"
}
variable "github_repo_name" {
  default = "terraform-ecs-codepipeline-demo"
}
variable "github_branch" {
  default = "main"
}
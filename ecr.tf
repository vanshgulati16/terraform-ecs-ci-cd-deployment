
resource "aws_ecr_repository" "ecr_repo" {
  name = "flask-demo-repo"

  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "MyECRRepo"
  }
}

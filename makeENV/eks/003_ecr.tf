#########################################################################################################
## Create docker image repository ECR
#########################################################################################################
resource "aws_ecr_repository" "repo" {
  name                 = "cwave-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
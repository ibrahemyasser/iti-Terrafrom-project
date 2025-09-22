
# resource "aws_s3_bucket" "terraform_state" {
#     bucket = "iti-project-terraform-state-10250"
#     object_lock_enabled = true

#     lifecycle {
#         prevent_destroy = true
#     }
# }

# resource "aws_s3_bucket_versioning" "enabled" {
#     bucket = aws_s3_bucket.terraform_state.id
#     versioning_configuration {
#         status = "Enabled"
#     }
# }

# resource "aws_dynamodb_table" "terraform_locks" {
#     name = "terraform-locks-1025"
#     billing_mode = "PAY_PER_REQUEST"
#     hash_key = "LockID"

#     attribute {
#         name = "LockID"
#         type = "S"
#     }
# }

terraform {
  backend "s3" {
    bucket         = "iti-project-terraform-state-10250"  
    key            = "dev/terraform.tfstate"  
    region         = "us-east-1"              
    encrypt        = true
    dynamodb_table = "terraform-locks-1025"        
  }
}
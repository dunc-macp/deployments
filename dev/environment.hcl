locals {
    environment = "dev"
    aws_profile_name = "floaty"
    state_bucket = "dmacp.terraform.state"
    dynamodb_table = "dmacp.terraform.${local.environment}.dynamodb"
}
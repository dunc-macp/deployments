
locals {
    aws_region = "eu-west-1"
    environment = read_terragrunt_config("${get_terragrunt_dir()}/../environment.hcl")
    path = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
    state_key = "${local.path}/terraform.tfstate"
    providers = {
        aws = "5.1.0"
        random = "3.5.1"
    }
}

remote_state {
    backend = "s3"
    config = {
        bucket = local.environment.locals.state_bucket
        key = local.state_key
        region = local.aws_region
        profile = local.environment.locals.aws_profile_name
        dynamodb_table = local.environment.locals.dynamodb_table
    }
}

generate "backend" {
    path = "backend.tf"
    if_exists = "overwrite"
    contents = <<EOF
terraform {
  backend "s3" {}
}
EOF
}

terraform {
    after_hook "show path" {
        commands = ["plan", "apply"]
        execute = ["bash", "${get_parent_terragrunt_dir()}/sh.sh", "${jsonencode(local)}"]
    }
}

inputs = {
    backend = {
        bucket = local.environment.locals.state_bucket,
        key = local.path
        region = local.aws_region
    }
}
include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  path = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
}

terraform {
  source = "../../../modules//${basename(get_terragrunt_dir())}"

  extra_arguments "aws_profile" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint",
      "destroy"
    ]

    env_vars = {
      AWS_PROFILE = "${local.account_vars.locals.aws_profile_name}"
    }
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${include.root.locals.providers.aws}"
    }
  }
}

provider "aws" {
  region = "${include.root.locals.aws_region}"
    default_tags {
        tags = {
            tf_module = "${local.path}"
        }
    }
}
EOF
}

inputs = {
}


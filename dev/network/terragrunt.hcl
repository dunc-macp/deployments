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
    random = {
      source = "hashicorp/random"
      version = "${include.root.locals.providers.random}"
    }
  }
}

provider "aws" {
  region = "${include.root.locals.aws_region}"
    default_tags {
        tags = {
            tg_module = "${local.path}"
        }
    }
}
EOF
}

inputs = {
  vpc_cidr = "10.0.0.0/16"
  public_subnets = {
    zone_a = {
      cidr = "10.0.1.0/24"
      availability_zone = "eu-west-1a"
    },
    zone_b = {
      cidr = "10.0.2.0/24"
      availability_zone = "eu-west-1b"
    }
  }
}


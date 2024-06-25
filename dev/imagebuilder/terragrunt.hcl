include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  path         = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
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
  contents  = <<EOF
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
  ami_sns_topic = "arn:aws:sns:us-east-1:137112412989:amazon-linux-2-ami-updates"
  imagebuilder_components = {
    python-linux-3 = {
      version = "1.0.2"
      enabled = false
    },
    update-linux = {
      version = "1.0.2"
      enabled = false
    },
    update-linux-kernel-5 = {
      version = "1.0.1"
      enabled = false
    },
    aws-cli-version-2-linux = {
      version = "1.0.4"
      enabled = false
    },
    amazon-cloudwatch-agent-linux = {
      version = "1.0.1"
      enabled = false
    },
    inspector-test-linux = {
      version = "1.0.6"
      enabled = false
    }
}
  terminate_instance_on_failure = true
}


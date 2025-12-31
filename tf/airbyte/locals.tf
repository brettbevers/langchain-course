locals {
  env = split("-", terraform.workspace)[0]

  name_prefix = "airbyte-${local.env}"

  common_tags = {
    Environment = local.env
    Service     = "airbyte"
    ManagedBy   = "terraform"
  }
}

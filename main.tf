provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  profile = "default"
}

module "single-account-cspm" {
  providers = {
    aws = aws.us-east-1
  }
  source           = "draios/secure-for-cloud/aws//modules/services/trust-relationship"
  role_name        = "sysdig-secure-5y59"
  trusted_identity = "arn:aws:iam::263844535661:role/gcp-us4-prod-usw1-secure-benchmark-assume-role"
  external_id      = "a765b2dea7a8694787b8b8c5a80440af"
}

module "single-account-threat-detection-us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source                  = "draios/secure-for-cloud/aws//modules/services/event-bridge"
  target_event_bus_arn    = "arn:aws:events:us-west-2:263844535661:event-bus/us-west-2-gcp-prod-us-4-falco-1"
  trusted_identity        = "arn:aws:iam::263844535661:role/gcp-us4-prod-usw1-secure-benchmark-assume-role"
  external_id             = "a765b2dea7a8694787b8b8c5a80440af"
  name                    = "sysdig-secure-events-y86o"
  deploy_global_resources = true
}

terraform {

  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 1.23.0"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url       = "https://app.us4.sysdig.com"
  sysdig_secure_api_token = "1f4cf8cf-93e1-4e42-bead-bc15fe62604d"
}

resource "sysdig_secure_cloud_auth_account" "aws_account_059797578166" {
  enabled       = true
  provider_id   = "059797578166"
  provider_type = "PROVIDER_AWS"

  feature {

    secure_threat_detection {
      enabled    = true
      components = ["COMPONENT_EVENT_BRIDGE/secure-runtime"]
    }

    secure_config_posture {
      enabled    = true
      components = ["COMPONENT_TRUSTED_ROLE/secure-posture"]
    }
  }
  component {
    type     = "COMPONENT_TRUSTED_ROLE"
    instance = "secure-posture"
    trusted_role_metadata = jsonencode({
      aws = {
        role_name = "sysdig-secure-5y59"
      }
    })
  }
  component {
    type     = "COMPONENT_EVENT_BRIDGE"
    instance = "secure-runtime"
    event_bridge_metadata = jsonencode({
      aws = {
        role_name = "sysdig-secure-events-y86o"
        rule_name = "sysdig-secure-events-y86o"
      }
    })
  }
}



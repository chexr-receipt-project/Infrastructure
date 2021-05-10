resource "aws_cognito_user_pool" "chexr_users" {
  # This is choosen when creating a user pool in the console
  name = "chexr_users"

   account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  # ATTRIBUTES
  alias_attributes = ["email", "phone_number"]

  # POLICY
  password_policy {
    minimum_length    = "8"
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  # MFA & VERIFICATIONS
  mfa_configuration        = "OFF"
  auto_verified_attributes = ["email"]

  # MESSAGE CUSTOMIZATIONS
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message_by_link = "Your life will be dramatically improved by signing up! {##Click Here##}"
    email_subject_by_link = "Welcome to to a new world and life!"
  }
  email_configuration {
    reply_to_email_address = "no-reply@chexr.com"
  }


  # DEVICES
  device_configuration {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }
}

# DOMAIN NAME
resource "aws_cognito_user_pool_domain" "chexr_user" {
  user_pool_id = aws_cognito_user_pool.chexr_users.id
  # DOMAIN PREFIX
  domain = "chexrusers"
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "receipts"
  name       = "Receipts Service"

  scope {
    scope_name        = "bank"
    scope_description = "access to banking resources"
  }

  scope {
    scope_name        = "merchant"
    scope_description = "access to merchant resources"
  }
  scope {
    scope_name        = "admin"
    scope_description = "access to admin resources"
  }

  user_pool_id = aws_cognito_user_pool.chexr_users.id
}
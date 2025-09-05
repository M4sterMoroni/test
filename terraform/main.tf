terraform {
  required_providers {
    prismacloudcompute = {
      source  = "PaloAltoNetworks/prismacloudcompute"
      version = "0.4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

# Configure the Prisma Cloud Compute Provider (for users and collections)
provider "prismacloudcompute" {
  console_url = var.console_url
  username    = var.username
  password    = var.password
}

# No need for manual authentication with Prisma Cloud provider

# Create admin user
resource "prismacloudcompute_user" "admin_user" {
  username            = "terraform-admin"
  password            = var.admin_password
  role                = "admin"
  authentication_type = "local"
}

# Create security analyst user
resource "prismacloudcompute_user" "security_analyst" {
  username            = "security-analyst"
  password            = var.analyst_password
  role                = "user"
  authentication_type = "local"
}

# Create viewer user
resource "prismacloudcompute_user" "viewer_user" {
  username            = "viewer-user"
  password            = var.viewer_password
  role                = "user"
  authentication_type = "local"
}

# Create custom role user
resource "prismacloudcompute_user" "custom_role_user" {
  username            = "custom-security-user"
  password            = var.custom_password
  role                = "user"
  authentication_type = "local"
}

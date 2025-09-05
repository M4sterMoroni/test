# Output user information
output "admin_user" {
  description = "Admin user details"
  value = {
    username = prismacloudcompute_user.admin_user.username
    role     = prismacloudcompute_user.admin_user.role
    status   = "created"
  }
  sensitive = false
}

output "security_analyst_user" {
  description = "Security analyst user details"
  value = {
    username = prismacloudcompute_user.security_analyst.username
    role     = prismacloudcompute_user.security_analyst.role
    status   = "created"
  }
  sensitive = false
}

output "viewer_user" {
  description = "Viewer user details"
  value = {
    username = prismacloudcompute_user.viewer_user.username
    role     = prismacloudcompute_user.viewer_user.role
    status   = "created"
  }
  sensitive = false
}

output "custom_role_user" {
  description = "Custom role user details"
  value = {
    username = prismacloudcompute_user.custom_role_user.username
    role     = prismacloudcompute_user.custom_role_user.role
    status   = "created"
  }
  sensitive = false
}

# Summary output
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    total_users = 4
    console_url = var.console_url
    environment = var.environment
    users_created = [
      prismacloudcompute_user.admin_user.username,
      prismacloudcompute_user.security_analyst.username,
      prismacloudcompute_user.viewer_user.username,
      prismacloudcompute_user.custom_role_user.username
    ]
  }
  sensitive = false
}

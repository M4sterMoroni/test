# Prisma Cloud Compute Configuration
variable "console_url" {
  description = "Prisma Cloud Compute Console URL"
  type        = string
  default     = "https://localhost:8083"
}

variable "username" {
  description = "Prisma Cloud Compute username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "password" {
  description = "Prisma Cloud Compute password"
  type        = string
  default     = "admin234"
  sensitive   = true
}

# User passwords
variable "admin_password" {
  description = "Password for admin user"
  type        = string
  default     = "AdminPass123!"
  sensitive   = true
}

variable "analyst_password" {
  description = "Password for security analyst user"
  type        = string
  default     = "AnalystPass123!"
  sensitive   = true
}

variable "viewer_password" {
  description = "Password for viewer user"
  type        = string
  default     = "ViewerPass123!"
  sensitive   = true
}

variable "custom_password" {
  description = "Password for custom role user"
  type        = string
  default     = "CustomPass123!"
  sensitive   = true
}

# Optional: Environment-specific configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "prisma-users"
}

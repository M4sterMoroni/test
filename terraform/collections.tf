# Prisma Cloud Collections and Policy Scoping
# This file manages collections and their scoping to policies

# Create collections
resource "prismacloudcompute_collection" "production_workloads_dev" {
  name        = "production-workloads-dev"
  description = "Production development workloads collection"
  color       = "#FF5733"
  
  # Scope the collection to specific resources
  images      = ["*"]
  hosts       = ["*"]
  labels      = ["env:production", "workload:dev"]
  containers  = ["*"]
  namespaces  = ["*"]
  clusters    = ["*"]
}

resource "prismacloudcompute_collection" "production_workloads_security" {
  name        = "production-workloads-security"
  description = "Production security workloads collection"
  color       = "#33FF57"
  
  # Scope the collection to specific resources
  images      = ["*"]
  hosts       = ["*"]
  labels      = ["env:production", "workload:security"]
  containers  = ["*"]
  namespaces  = ["*"]
  clusters    = ["*"]
}

# Output collection information
output "collections" {
  description = "Created collections"
  value = {
    dev_collection = {
      name        = prismacloudcompute_collection.production_workloads_dev.name
      description = prismacloudcompute_collection.production_workloads_dev.description
      color       = prismacloudcompute_collection.production_workloads_dev.color
    }
    security_collection = {
      name        = prismacloudcompute_collection.production_workloads_security.name
      description = prismacloudcompute_collection.production_workloads_security.description
      color       = prismacloudcompute_collection.production_workloads_security.color
    }
  }
}

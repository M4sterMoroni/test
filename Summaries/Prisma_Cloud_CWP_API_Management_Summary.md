# Summary: Prisma Cloud CWP API for Collections and Policy Management

## Objective
The goal was to programmatically create and configure asset collections in a local Prisma Cloud Compute Edition (v34.00.141) environment. The tasks were to create at least one collection, then scope it to both a vulnerability policy and a compliance policy.

## Initial Approach: Terraform
The initial attempt utilized the official `PaloAltoNetworks/prismacloudcompute` Terraform provider.

#### Challenge:
The process failed consistently with `400 Bad Request` errors when trying to create collections. Debugging revealed that even with minimal configuration, the Terraform provider was sending default wildcard values (`*`) for unsupported or unconfigured scopes (e.g., `AccountIds`, `AppIds`, `Clusters`). This indicates an incompatibility between the latest provider versions and the older, self-hosted console version. Downgrading the provider was not a viable solution as older versions were not available in the registry.

#### Conclusion:
The Terraform provider is not a reliable method for managing collections on this specific version of Prisma Cloud Compute Edition due to API schema mismatches.

---

## Revised Approach: Direct API Interaction via PowerShell
The strategy was revised to use PowerShell to interact directly with the Prisma Cloud Compute API. This provided the necessary control to build compatible requests.

## Key Discoveries & Learnings

### 1. API Authentication & Connectivity
- **Authentication:** Standard JWT-based authentication. A `POST` request to `/api/v1/authenticate` with a `username` and `password` body returns a bearer token.
- **Certificate Handling:** For local development with self-signed certificates, PowerShell requires a script-level bypass for TLS validation, as the `-SkipCertificateCheck` parameter is not available in all versions.

### 2. Collection Management (`/api/v1/collections`)
- **Creation/Updates:** Collections can be created (`POST`) and updated (`PUT` to `/api/v1/collections/<collection_name>`).
- **Image Name Formatting:** A critical discovery was that this API version **does not support registry wildcards** in image names. An image name like `*/dev-*:*` is invalid. The correct, compatible format is `dev-*` or `nginx:latest`.
- **Default Wildcard Behavior:** When a collection is created with a specific scope (e.g., only `images`), the API automatically populates all other scope fields (`containers`, `hosts`, `labels`, etc.) with a wildcard (`*`) in the backend. This is expected behavior.

### 3. Vulnerability Policy Scoping (`/api/v1/policies/vulnerability/...`)
- **Structure:** The vulnerability policy endpoints (e.g., `/api/v1/policies/vulnerability/images`) return an **array of policy objects**.
- **Scoping Method:** To add a collection, the script must:
    1. `GET` the list of policies.
    2. Select a policy object from the array (e.g., the first one).
    3. Add the collection **name as a string** to the policy's `.collections` array.
    4. `PUT` the entire modified policy object back to the API.

### 4. Compliance Policy Scoping (`/api/v1/policies/compliance/container`)
- **Structure:** This was the most significant discovery. This endpoint returns a **single, global document**, not an array. This document contains a property named `rules`, which is an array of all the individual compliance rules.
- **Scoping Method:** The process is fundamentally different:
    1. `GET` the single policy document.
    2. Find the specific rule to modify within the `.rules` array (e.g., by its `name`).
    3. The `.collections` property for a rule requires an array of **collection objects**, not simple strings. Adding a string causes a `cannot unmarshal string into Go struct` error.
    4. The script must add a minimal object, like `@{ name = "collection-name" }`, to the rule's `.collections` array.
    5. `PUT` the entire, modified document back to the endpoint.

## Final Solution
The `terraform/` folder was repurposed to hold the final, working PowerShell scripts that successfully achieved the objective.

- **`create-collections.ps1`:** Creates two collections with compatible image name formats.
- **`scope-collections-to-vuln-policy.ps1`:** Scopes the collections to a vulnerability policy by adding their names (strings).
- **`scope-collections-to-compliance-policy.ps1`:** Scopes the collections to a compliance policy rule by adding them as objects.
- **Diagnostic Scripts:** `debug-compliance-policy.ps1` and `verify-scope.ps1` were created as essential tools for inspecting API responses and verifying results.

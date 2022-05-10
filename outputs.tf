#output "myoutput" {
#  description = "Description of my output"
#  value       = "value"
#  depends_on  = [<some resource>]
#}

output "name" {
  description = "The name of the module"
  value       = local.name
  depends_on  = [null_resource.setup_gitops_subscription]
}

output "branch" {
  description = "The branch where the module config has been placed"
  value       = local.application_branch
  depends_on  = [null_resource.setup_gitops_subscription]
}

output "namespace" {
  description = "The namespace where the module will be deployed"
  value       = local.namespace
  depends_on  = [null_resource.setup_gitops_subscription]
}

output "server_name" {
  description = "The server where the module will be deployed"
  value       = var.server_name
  depends_on  = [null_resource.setup_gitops_subscription]
}

output "layer" {
  description = "The layer where the module is deployed"
  value       = local.layer
  depends_on  = [null_resource.setup_gitops_subscription]
}

output "type" {
  description = "The type of module where the module is deployed"
  value       = local.type
  depends_on  = [null_resource.setup_gitops_subscription]
}
module "gitops_cp4d_operator" {
  depends_on = [
    module.gitops_ibm_catalogs
  ]
  source = "https://github.com/cloud-native-toolkit/terraform-gitops-db2u-operator"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  namespace = module.gitops_namespace.name
}
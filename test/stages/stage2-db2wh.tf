module "db2wh" {
  source = "./module"

  gitops_config            = module.gitops.gitops_config
  git_credentials          = module.gitops.git_credentials
  server_name              = module.gitops.server_name
  namespace                = module.gitops.namespace
  kubeseal_cert            = module.gitops.sealed_secrets_cert

  operator_namespace= "cpd-operators"  
  cpd_namespace = "gitops-cp4d-instance"
  common_services_namespace = "ibm-common-services"
}


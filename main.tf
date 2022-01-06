locals {
  name         = "db2warehouse"
  bin_dir      = module.setup_clis.bin_dir
  yaml_dir     = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  ingress_host = "${local.name}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url  = "https://${local.ingress_host}"
  service_url  = "http://${local.name}.${var.namespace}"
  values_content = {
    operator_namespace = var.namespace
    storage_class      = "portworx-shared-gp3"

    cpd_platform_version  = "4.0.2"
    cpd_platform_channel  = "v2.0"
    db2_warehouse_version = "4.0.2"
    db2_warehouse_channel = "v1.0"
    cpd_namespace         = "cpd"
  }
  layer              = "services"
  application_branch = "main"
  layer_config       = var.gitops_config[local.layer]
}

module "setup_clis" {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  gitops_config            = module.gitops.gitops_config
  git_credentials          = module.gitops.git_credentials
  server_name              = module.gitops.server_name
  namespace                = module.gitops_namespace.name
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  cluster_type             = module.dev_cluster.platform.type_code
  tls_secret_name          = module.dev_cluster.platform.tls_secret
  kubeseal_cert            = module.argocd-bootstrap.sealed_secrets_cert
}

module "gitops_ibm_catalogs" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs"
}

module "gitops_cp4d_operator" {
  depends_on = [
    gitops_ibm_catalogs
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-cp4d-operator"
}

resource "null_resource" "create_yaml" {
  depends_on = [
    gitops_ibm_catalogs,
    gitops_cp4d_operator
  ]
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}' "

    environment = {
      OPERATOR_NAMESPACE = local.values_content.operator_namespace
      STORAGE_CLASS      = local.values_content.storage_class
      CPD_NAMESPACE      = local.values_content.cpd_namespace

      CPD_PLATFORM_VERSION = local.values_content.cpd_platform_version
      CPD_PLATFORM_CHANNEL = local.values_content.cpd_platform_channel

      DB2_WAREHOUSE_VERSION = local.values_content.db2_warehouse_version
      DB2_WAREHOUSE_CHANNEL = local.values_content.db2_warehouse_channel
    }
  }
}

resource "null_resource" "debug_yamls" {
  depends_on = [null_resource.create_yaml]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cat ${local.yaml_dir}/*.yaml"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource "null_resource" "setup_gitops" {
  depends_on = [null_resource.create_yaml, null_resource.debug_yamls]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}

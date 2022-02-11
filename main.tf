locals {
  name         = "db2warehouse"
  bin_dir      = module.setup_clis.bin_dir
  yaml_dir     = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  ingress_host = "${local.name}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url  = "https://${local.ingress_host}"
  service_url  = "http://${local.name}.${var.namespace}"
  values_content = {
  }
  layer              = "services"
  application_branch = "main"
  layer_config       = var.gitops_config[local.layer]
}

module "setup_clis" {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}


resource "null_resource" "create_yaml" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}' "

    environment = {
      CS_NAMESPACE            = var.common_services_namespace
      STORAGE_CLASS           = var.storage_class
      INSTANCE_NAMESPACE      = var.namespace

      DB2_WAREHOUSE_VERSION = var.db2_warehouse_version
      DB2_WAREHOUSE_CHANNEL = var.db2_warehouse_channel
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

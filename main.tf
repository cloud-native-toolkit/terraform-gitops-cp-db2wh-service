locals {
  name         = "db2warehouse"
  bin_dir      = module.setup_clis.bin_dir
  yaml_dir     = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  ingress_host = "${local.name}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url  = "https://${local.ingress_host}"
  service_url  = "http://${local.name}.${var.namespace}"

  db2whoperatorcatalog-subscription = {


  }

  db2whoperator-services = {
    apiVersion = databases.cpd.ibm.com/v1
    kind = Db2whService
      metadata = {
        name = db2wh-cr    
        namespace = ibm-common-services   
      spec = { 
        license = { 
          accept = true
          license = Enterprise  
        }
      }
    } 
  }

  values_content = {
    db2whoperator-services = local.dbwhoperator-services
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
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

      VALUES_CONTENT = yamlencode(local.values_content)
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

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}


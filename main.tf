locals {
  name         = "ibm-cpd-db2wh-instance"
  subscription_name  = "ibm-cpd-db2wh-subscription"
  operandregistry_name = "ibm-cpd-db2wh-operandregistry"

  bin_dir      = module.setup_clis.bin_dir

  subscription_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.subscription_name}"
  instance_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  operandregistry_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.operandregistry_name}"

  yaml_dir     = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  chart_dir    = "${path.module}/charts/ibm-db2wh"

  ingress_host = "${local.name}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url  = "https://${local.ingress_host}"
  service_url  = "http://${local.name}.${var.namespace}"

  sa_name       = "ibm-db2-ibm-db2"
  
  layer = "services"
  operator_type  = "operators"
  type  = "instances"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]

  subscription_content = {
    license_accept = true
    license = var.license

    db2wh_namespace =var.namespace
    db2wh_version =var.db2_warehouse_version
    db2wh_channel=var.db2_warehouse_channel


    name= "ibm-db2wh-cp4d-operator-catalog-subscription"
    operator_namespace = var.operator_namespace
    common_services_namespace = var.common_services_namespace
    cpd_namespace = var.cpd_namespace
  }

  instance_content = {
    name = "db2wh-cr"
    cpd_namespace = var.cpd_namespace
    operator_namespace = var.operator_namespace
    spec = {
      license = {
        accept = "true"
        license = var.license 
        } 
      db_type = "db2wh" 
      }               
    }

}

module "setup_clis" {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

module setup_service_account {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-account.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = local.namespace
  name = "db2wh-operandreg-sa"
  server_name = var.server_name    
}

module setup_rbac {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.7.1"

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = local.namespace
  service_account_name      = "db2wh-operandreg-sa"
  namespace                 = var.common_services_namespace
  rules                     = [
    {
      apiGroups = ["operator.ibm.com"]
      resources = ["operandregistries"]
      verbs = ["get", "apply", "list", "patch"]
    }
  ]
  server_name               = var.server_name
  cluster_scope             = true
}

resource null_resource create_operandregistry_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.operandregistry_name}' '${local.operandregistry_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.subscription_content)
    }
  }
}

resource null_resource setup_gitops_operandregistry {
  depends_on = [null_resource.create_operandregistry_yaml]

  triggers = {
    name = local.operandregistry_name
    namespace = var.namespace
    yaml_dir = local.operandregistry_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.operator_type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
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

resource "null_resource" "create_subcription_yaml" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.subscription_name}' '${local.subscription_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.subscription_content)
    }

  }
}



/* resource "null_resource" "debug_yamls" {
  depends_on = [null_resource.create_subcription_yaml]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cat ${local.yaml_dir}/*.yaml"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
} */

resource null_resource setup_gitops_subscription {
  depends_on = [null_resource.create_subcription_yaml]

  triggers = {
    name = local.subscription_name
    namespace = var.namespace
    yaml_dir = local.subscription_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.operator_type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
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

resource null_resource create_instance_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.instance_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.instance_content)
    }
  }
}

resource null_resource setup_gitops_instance {
  depends_on = [null_resource.create_instance_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.instance_yaml_dir
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
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
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
